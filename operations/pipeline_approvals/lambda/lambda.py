import json
import logging
import os
import re
import time
from urllib import request

import boto3

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

MAX_WAIT_FOR_RESPONSE = 10
WAIT_INCREMENT = 1


class PipelineStateError(Exception):
    pass


class PipelineStageNotFoundError(PipelineStateError):
    pass


class PipelineActionNotFoundError(PipelineStateError):
    pass


class PipelineMissingKeyError(PipelineStateError):
    pass


def _get_stage_from_response(response, stage_name):
    """ Extract information about a specific stage from a pipeline response.
    :param response: The API response
    :param stage_name: The stage to extract
    :return: The stage information
    """
    try:
        return next(s for s in response['stageStates']
                    if s['stageName'] == stage_name)
    except StopIteration:
        raise PipelineStageNotFoundError(stage_name)


def _get_actions_from_stage(stage, pattern):
    """ Extract information for matching actions in a stage.
    :param stage: The stage from which to extract the actions
    :param pattern: The pattern used to match the action name
    :return: A list containing the action information
    """
    try:
        actions = list(a for a in stage['actionStates']
                       if re.search(pattern, a['actionName']) and a['latestExecution'] is not None)
        if actions is None or len(actions) == 0:
            raise PipelineActionNotFoundError(pattern)
        return actions
    except KeyError as e:
        # The actions in the response only includes the key `latestExection` if
        # the action has started. Sometimes, the API does not reflect that the
        # approval action has started even though SNS has been notified.
        # If that is the case, we return a `PipelineMissingKeyError` so that the
        # caller can retry the call.
        raise PipelineMissingKeyError(e)


def _get_state(codepipeline, pipeline_name, stage_name, approval_action):
    """Fetches the state of the actions from the pipeline stage.
    Sometimes the SNS notification reaches lambda before the CodePipeline API
    has been updated with the latest execution. If that is the case we retry
    every `WAIT_INCREMENT` second(s) for a maximum of `MAX_WAIT_FOR_RESPONSE`
    second(s).
    :param codepipeline: A CodePipeline boto client
    :param pipeline_name: The name of the pipeline
    :param stage_name: The name of the stage
    :param approval_action: The name of the manual approval action
    :return: Tuple containing (approval_action_state, plan_action_states)
    """
    wait = 0

    while wait <= MAX_WAIT_FOR_RESPONSE:
        try:
            logger.info('Fetching pipeline state.')
            response = codepipeline.get_pipeline_state(name=pipeline_name)

            stage = _get_stage_from_response(response, stage_name)
            approval_action_state = _get_actions_from_stage(stage, approval_action)[0]  # There should be only 1
            plan_action_states = _get_actions_from_stage(stage, 'Plan$')

            return approval_action_state, plan_action_states
        except PipelineMissingKeyError:
            logger.warning('Response does not contain latest execution yet. '
                           'Waiting for %d seconds.' % WAIT_INCREMENT)
            time.sleep(WAIT_INCREMENT)
            wait += WAIT_INCREMENT
    else:
        raise TimeoutError


def handler(event, context):
    logger.debug(json.dumps(event))
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])

    token = sns_message['approval']['token']
    pipeline = sns_message['approval']['pipelineName']
    stage = sns_message['approval']['stageName']
    approval_action = sns_message['approval']['actionName']
    approval_url = sns_message['approval']['approvalReviewLink']

    logs = boto3.client('logs')
    codebuild = boto3.client('codebuild')
    codepipeline = boto3.client('codepipeline')

    try:
        approval_action_state, plan_action_states = _get_state(codepipeline, pipeline, stage, approval_action)
    except PipelineStageNotFoundError as e:
        logger.error('Pipeline response did not contain expected stage: {}'.format(e))
        return
    except PipelineActionNotFoundError as e:
        logger.error('Pipeline response did not contain expected action: {}'.format(e))
        return
    except TimeoutError:
        logger.error('Did not get complete pipeline response within {} seconds.'.format(MAX_WAIT_FOR_RESPONSE))
        return

    state_approval_token = approval_action_state['latestExecution'].get('token')

    if not state_approval_token:
        logger.info('Response did not include an approval token.')
        return

    if not state_approval_token == token:
        logger.info('Token in SNS event does not match token in response.')
        return

    for state in plan_action_states:
        if not state['latestExecution'].get('status') == "Succeeded":
            logger.info('{} does not have a successful status.'.format(state.get('actionName')))
            return

    builds = codebuild.batch_get_builds(ids=list(state['latestExecution']['externalExecutionId']
                                                 for state in plan_action_states))['builds']
    logs = logs.filter_log_events(logGroupName=builds[0].get('logs').get('groupName'),
                                  logStreamNames=list(build.get('logs').get('streamName')
                                                      for build in builds),
                                  filterPattern='"TERRAFORM PLAN HAS FOUND SOME CHANGES"')['events']

    if len(logs) == 0:
        logger.info('No changes detected. Automatically approving request.')
        codepipeline.put_approval_result(
            pipelineName=pipeline,
            stageName=stage,
            actionName=approval_action,
            token=token,
            result={
                'summary': '*AUTOMATED* No changes. Infrastructure is up-to-date.',
                'status': 'Approved'
            }
        )
    else:
        logger.info('Changes were detected in one or more plans:')
        output = ''
        for log in logs:
            build_id = next(build['id'] for build in builds
                            if build['logs']['streamName'] == log['logStreamName'])
            build_name = next(state['actionName'] for state in plan_action_states
                              if state['latestExecution']['externalExecutionId'] == build_id)
            output += '[{}] {}'.format(build_name, log['message'])
        logger.info(output)

        pipeline_name = pipeline.replace(f'{os.environ["environment_name"]}-', '')
        res = request.urlopen(request.Request(
            url='https://hooks.slack.com/services/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',
            data=json.dumps({
                "channel": "# " + os.environ['slack_channel'],
                "icon_emoji": ":amazon:",
                "username": "Infrastructure Change Notification",
                "link_names": "1",
                "text": f':terraform: *Terraform Changes*'
                        f'\n Infrastructure changes are awaiting user approval.'
                        f'\n> Environment:		{os.environ["environment_name"]}'
                        f'\n> Pipeline:			*{pipeline_name}*'
                        f'\n> Stage:			{stage}'
                        f'\n> Summary:'
                        f'\n```'
                        f'\n{output}'
                        f'```'
                        f'\n<{approval_url}|Review changes>'
            }).encode('utf-8')), timeout=10)
        logger.info(f'Sent Slack notification. Response: {res.getcode()}')
