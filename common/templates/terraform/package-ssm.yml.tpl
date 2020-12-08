---
version: 0.2

env:
  variables:
    ENV_CONFIGS_REPO: "https://github.com/ministryofjustice/hmpps-env-configs.git"
  parameter-store:
    ENV_CONFIGS_VERSION: "/versions/mis/repo/hmpps-env-configs/$${ENVIRONMENT_NAME}"
    HMPPS_GITHUB_USER: "/dev/jenkins/hmpps/integration/user/name"
    HMPPS_GITHUB_TOKEN: "/manually/created/engineering/dev/codepipeline/github/accesstoken"
    HMPPS_GITHUB_EMAIL: "/jenkins/github/email"

phases:
  pre_build:
    commands:
      - rm -rf $${CODEBUILD_SRC_DIR}/utils $${CODEBUILD_SRC_DIR}/run.sh $${CODEBUILD_SRC_DIR}/Makefile $${CODEBUILD_SRC_DIR}/docker-run.py
      - cp -r $${CODEBUILD_SRC_DIR_utils}/* $${CODEBUILD_SRC_DIR}/

  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - export PACKAGE_VERSION="$(python utils/manage.py generate-build-version)-alpha" || (exit $?)
      - export LATEST_PATH="alpha"
      - |
        if [ $${CODEBUILD_INITIATOR} == "$${DEV_PIPELINE_NAME}" ]; then
          echo "Waiting for Github Action to complete"
          sleep 120
          export PACKAGE_VERSION=$(python utils/manage.py get-version) || (exit $?)
          export LATEST_PATH="latest"
        fi
      - make $${TASK} component=$${COMPONENT}

artifacts:
  files:
    - '**/*.tar'
