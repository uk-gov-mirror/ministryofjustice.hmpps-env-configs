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
      - cp -r $${CODEBUILD_SRC_DIR_utils}/utils/* $${CODEBUILD_SRC_DIR}/utils

  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - export PACKAGE_VERSION="$(python utils/manage.py generate-build-version)-alpha" || (exit $?)
      - |
        if [ $${CODEBUILD_INITIATOR} == "$${DEV_PIPELINE_NAME}" ]; then
          python utils/manage.py create-tag -sha $${CODEBUILD_RESOLVED_SOURCE_VERSION} || (exit $?)
          sleep 15
          export PACKAGE_VERSION=$(python utils/manage.py get-version) || (exit $?)
        fi
      - echo "export PACKAGE_VERSION=$${PACKAGE_VERSION}" >> build.properties

artifacts:
  files:
    - '**/*'
