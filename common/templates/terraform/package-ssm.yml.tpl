---
version: 0.2

env:
  variables:
    ENV_CONFIGS_REPO: "https://github.com/ministryofjustice/hmpps-env-configs.git"
  parameter-store:
    ENV_CONFIGS_VERSION: "/versions/mis/repo/hmpps-env-configs/$${ENVIRONMENT_NAME}"

phases:
  pre_build:
    commands:
      - rm -rf $${CODEBUILD_SRC_DIR}/utils $${CODEBUILD_SRC_DIR}/run.sh $${CODEBUILD_SRC_DIR}/Makefile $${CODEBUILD_SRC_DIR}/docker-run.py
      - cp -r $${CODEBUILD_SRC_DIR_utils}/* $${CODEBUILD_SRC_DIR}/

  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - make $${TASK} component=$${COMPONENT}

artifacts:
  files:
    - '**/*.tar'
