---
version: 0.2

env:
  variables:
    ENV_CONFIG_DIR: "account_configs"
    RUN_SHELL_SRC: "scripts/engineering"

phases:
  pre_build:
    commands:
      - rm -rf $CODEBUILD_SRC_DIR/utils $CODEBUILD_SRC_DIR/run.sh $CODEBUILD_SRC_DIR/docker-run.py
      - cp -r $CODEBUILD_SRC_DIR_utils/* $CODEBUILD_SRC_DIR/
      - cp $CODEBUILD_SRC_DIR/$RUN_SHELL_SRC/run.sh $CODEBUILD_SRC_DIR/run.sh
      
  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$CODEBUILD_SRC_DIR
      - make $TASK component=$COMPONENT

artifacts:
  base-directory: '$${CODEBUILD_SRC_DIR}'
  files:
    - '**/*'

