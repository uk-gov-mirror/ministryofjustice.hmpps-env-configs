---
version: 0.2

phases:
  build:
    commands:
      - echo "Waiting for terraform package to be uploaded!"
      - sleep 120
      - aws codepipeline start-pipeline-execution --name alf-infra-build-delius-core-dev
      - aws codepipeline start-pipeline-execution --name alf-infra-build-delius-int
      - aws codepipeline start-pipeline-execution --name alf-infra-build-delius-auto-test
