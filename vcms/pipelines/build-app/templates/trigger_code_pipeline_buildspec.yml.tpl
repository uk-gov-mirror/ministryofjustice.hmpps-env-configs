---
version: 0.2
env:
  shell: bash
  variables:
    REGION: "eu-west-2"

phases:
  build:
    commands:
      - BRANCH_NAME=$(cat builds/branch_name.txt)
      - echo $BRANCH_NAME

      - |-
           if [[ $PROMOTION_LEVEL == "test" ]] || [[ $PROMOTION_LEVEL == "perf" ]]  || [[ $PROMOTION_LEVEL == "stage" ]]; then
               if [[ $BRANCH_NAME == "master" ]]   ||  [[ $BRANCH_NAME == "staging" ]] || [[ $BRANCH_NAME == release* ]]; then
                   PIPELINE_NAME="$TARGET_PIPELINE"
                   echo "Branch $BRANCH_NAME set for promotion to vcms$PROMOTION_LEVEL via PIPELINE $PIPELINE_NAME"
               fi
           fi

      - |-
           if [[ $PROMOTION_LEVEL == "preprod" ]]; then
               if [[ $BRANCH_NAME == release* ]]   ||  [[ $BRANCH_NAME == hotfix* ]]; then
                   PIPELINE_NAME="$TARGET_PIPELINE"
                   echo "Branch $BRANCH_NAME set for promotion to vcms$PROMOTION_LEVEL via PIPELINE $PIPELINE_NAME"
               fi
           fi

      - |-
           if [ -z $PIPELINE_NAME ]; then
               echo "Branch $BRANCH_NAME does not qualify to be promoted to $TARGET_PIPELINE"
           else
               echo "Triggering codepipeline $PIPELINE_NAME"
               APP_VERSION=$(cat builds/semvertag.txt)

               #Check if pipeline is running.
               PIPELINE_EXECUTION_STATUS=$(aws codepipeline list-pipeline-executions  --pipeline-name $PIPELINE_NAME --max-items 1  --region $REGION | jq -r .pipelineExecutionSummaries[0].status)      || exit 1

               while [ $PIPELINE_EXECUTION_STATUS == "InProgress" ]
               do
                  echo "Pipeline $PIPELINE_NAME is running, awaiting completion of current execution before proceeding"
                  sleep 30
                  PIPELINE_EXECUTION_STATUS=$(aws codepipeline list-pipeline-executions  --pipeline-name $PIPELINE_NAME --max-items 1  --region $REGION | jq -r .pipelineExecutionSummaries[0].status) || exit 1
               done

               echo "Creating SSM Param /codepipeline/temp/deploy/version/$PIPELINE_NAME"
               sleep 30
               aws ssm put-parameter --name "/codepipeline/temp/deploy/version/$PIPELINE_NAME" --type "String"  --value "$APP_VERSION"  --description "$APP_VERSION" --region "$REGION" || exit 1

               #Trigger Pipeline
               EXECUTION_ID=$(aws codepipeline start-pipeline-execution --name $PIPELINE_NAME | jq -r .pipelineExecutionId) || exit 1
               sleep 60

               #Check triggered pipeline status
               PIPELINE_STATUS=$(aws codepipeline get-pipeline-execution --pipeline-name $PIPELINE_NAME --pipeline-execution-id $EXECUTION_ID | jq -r .pipelineExecution.status)

               while [ $PIPELINE_STATUS == "InProgress" ]
               do
                  echo "PIPELINE $PIPELINE_NAME  EXECUTION_ID $EXECUTION_ID status is $PIPELINE_STATUS"
                  sleep 15
                  PIPELINE_STATUS=$(aws codepipeline get-pipeline-execution --pipeline-name $PIPELINE_NAME --pipeline-execution-id $EXECUTION_ID | jq -r .pipelineExecution.status) || exit 1
               done

               #Exit on failure
               if [ "$PIPELINE_STATUS" != "Succeeded" ]; then
                 echo "PIPELINE $PIPELINE_NAME  EXECUTION_ID $EXECUTION_ID status is $PIPELINE_STATUS"
                 echo exiting
                 exit 1
               fi

               echo "PIPELINE $PIPELINE_NAME  EXECUTION_ID $EXECUTION_ID status is $PIPELINE_STATUS"
           fi

    finally:
      - |-
           if [ ! -z $PIPELINE_NAME ]; then
               aws ssm delete-parameter --name "/codepipeline/temp/deploy/version/$PIPELINE_NAME"
           fi
