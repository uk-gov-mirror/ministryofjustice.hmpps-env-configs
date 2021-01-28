---
version: 0.2

phases:
  build:
    commands:
      - echo "Waiting for terraform package to be uploaded!"
      - sleep 120
      - aws codepipeline start-pipeline-execution --name alf-infra-build-delius-core-dev
      - echo "Waiting for previous pipeline before triggering next pipeline"
      - sleep 180
      - aws codepipeline start-pipeline-execution --name alf-infra-build-delius-int
      - echo "Waiting for previous pipeline before triggering next pipeline"
      - sleep 180
      - aws codepipeline start-pipeline-execution --name alf-infra-build-delius-auto-test
      - echo "complete"
