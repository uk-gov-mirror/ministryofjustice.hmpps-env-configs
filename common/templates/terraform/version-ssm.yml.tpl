---
version: 0.2

env:
  variables:
    SSM_PACKAGE_VERSION: "$${VERSION_SSM_PATH}/$${ENVIRONMENT_NAME}"
    TG_REGION: eu-west-2

phases:
  pre_build:
    commands:
      - export PACKAGE_VERSION=$$(aws ssm get-parameters --with-decryption --names $${SSM_PACKAGE_VERSION} --region $${TG_REGION}  --query "Parameters[0]"."Value")
      - env | grep "PACKAGE_VERSION"

  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - make get_package || (exit $?)

artifacts:
  files:
    - '**/*.tar'
