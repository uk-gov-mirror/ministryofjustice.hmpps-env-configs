---
version: 0.2

env:
  parameter-store:
    HMPPS_GITHUB_USER: "/dev/jenkins/hmpps/integration/user/name"
    HMPPS_GITHUB_TOKEN: "/manually/created/engineering/dev/codepipeline/github/accesstoken"
    HMPPS_GITHUB_EMAIL: "/jenkins/github/email"

phases:
  pre_build:
    commands:
      - rm -rf $${CODEBUILD_SRC_DIR}/utils $${CODEBUILD_SRC_DIR}/run.sh $${CODEBUILD_SRC_DIR}/Makefile $${CODEBUILD_SRC_DIR}/docker-run.py
      - cp -r $${CODEBUILD_SRC_DIR_utils}/* $${CODEBUILD_SRC_DIR}/
      - test -f "configs/common.properties" && source "configs/common.properties"

  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - export PACKAGE_VERSION="$(python utils/manage.py generate-build-version)-alpha" || (exit $?)
      - |
        if [ $${CODEBUILD_INITIATOR} == "$${DEV_PIPELINE_NAME}" ]; then
          python utils/manage.py create-release -sha $${CODEBUILD_RESOLVED_SOURCE_VERSION} || (exit $?)
          sleep 15
          export PACKAGE_VERSION=$(python utils/manage.py get-version) || (exit $?)
        fi
      - make $${TASK} component=$${COMPONENT}

artifacts:
  files:
    - '**/*.tar'
