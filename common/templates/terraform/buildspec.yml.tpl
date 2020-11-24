---
version: 0.2

phases:
  pre_build:
    commands:
      - rm -rf $CODEBUILD_SRC_DIR/utils $CODEBUILD_SRC_DIR/run.sh $CODEBUILD_SRC_DIR/Makefile $CODEBUILD_SRC_DIR/docker-run.py
      - cp -r $CODEBUILD_SRC_DIR_utils/* $CODEBUILD_SRC_DIR/
      - test -f "configs/common.properties" && source "configs/common.properties"
      
  build:
    commands:
      - export HMPPS_BUILD_WORK_DIR=$CODEBUILD_SRC_DIR
      - make $TASK component=$COMPONENT

