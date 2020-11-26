---
version: 0.2

env:
  variables:
    TF_PLUGIN_CACHE_DIR: /tmp/tf-plugin-cache
    RUNNING_IN_CONTAINER: "True"

phases:
  pre_build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - tar xf tfpackage.tar -C $${CODEBUILD_SRC_DIR} --strip-components=2 || exit $?
  build:
    commands:
      - make $${TASK} component=$${COMPONENT} || (exit $$?)

cache:
  paths:
    - '/tmp/tf-plugin-cache/**/*'
