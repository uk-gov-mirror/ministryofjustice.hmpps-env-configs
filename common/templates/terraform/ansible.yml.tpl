---
version: 0.2

env:
  variables:
    RUNNING_IN_CONTAINER: "True"

phases:
  pre_build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$${CODEBUILD_SRC_DIR}
      - tar xf tfpackage.tar -C $${CODEBUILD_SRC_DIR} --strip-components=2 || exit $?
  build:
    commands:
      - |
        if [ $${TASK} == "ansible" ]; then
          sh run.sh $${ENVIRONMENT_NAME} $${TASK} $${COMPONENT} || (exit $$?)
        fi
