---
version: 0.2

env:
  parameter-store:
    PACKAGE_VERSION: "$${VERSION_SSM_PATH}/$${ENVIRONMENT_NAME}"

phases:
  pre_build:
    commands:
      - echo $${PACKAGE_VERSION} > output.txt
      - cat output.txt

  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - make get_package || (exit $?)

artifacts:
  files:
    - '**/*.tar'
