---
version: 0.2
env:
  variables:
    REGION: "eu-west-2"

phases:
  build:
    commands:
      - echo "Triggering codepipeline $PIPELINE_NAME"
      - BRANCH_NAME=$(cat builds/branch_name.txt) || exit 1
      - APP_VERSION=$(cat builds/semvertag.txt)   || exit 1
      - aws codepipeline get-pipeline --name $PIPELINE_NAME > pipeline.json || exit 1
      - cp pipeline.json  temp_pipeline.json
      - sed -i "s/current_eb_version/\$APP_VERSION/" temp_pipeline.json
      - aws codepipeline update-pipeline --pipeline $PIPELINE_NAME   --cli-input-json file://temp_pipeline.json || exit 1
      - EXECUTION_ID=$(aws codepipeline start-pipeline-execution --name $PIPELINE_NAME | jq -r .pipelineExecutionId) || exit 1
      - PIPELINE_STATUS=$(aws codepipeline get-pipeline-execution --pipeline-name $PIPELINE_NAME --pipeline-execution-id $EXECUTION_ID | jq -r .pipelineExecution.status)
      - |-
           while [ $PIPELINE_STATUS == "InProgress" ]
           do
            echo "PIPELINE $PIPELINE_NAME  EXECUTION_ID $EXECUTION_ID status is $PIPELINE_STATUS"
             sleep 15
             PIPELINE_STATUS=$(aws codepipeline get-pipeline-execution --pipeline-name $PIPELINE_NAME --pipeline-execution-id $EXECUTION_ID | jq -r .pipelineExecution.status) || exit 1
           done

      - |-
           if [ "$PIPELINE_STATUS" != "Succeeded" ]; then
             echo "PIPELINE $PIPELINE_NAME  EXECUTION_ID $EXECUTION_ID status is $PIPELINE_STATUS"
             echo exiting
             exit 1
           fi

      - echo "PIPELINE $PIPELINE_NAME  EXECUTION_ID $EXECUTION_ID status is $PIPELINE_STATUS"

    finally:
      - aws codepipeline update-pipeline  --pipeline $PIPELINE_NAME --cli-input-json file://pipeline.json
