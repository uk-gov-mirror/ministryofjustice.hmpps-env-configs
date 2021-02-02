---
version: 0.2
env:
  variables:
    ECR_PREFIX: "dkr.ecr.eu-west-2.amazonaws.com"

phases:
  build:
    commands:
      - cd builds
      - BUILD_TAG=$(cat semvertag.txt) || exit 1
      - echo "Version is $BUILD_TAG"
      - $(aws ecr get-login --no-include-email --region eu-west-2)

      - |-
           if [ "$DOCKER_IMAGE_TYPE" = "vcms" ]; then
             BUILD_ARGS="--build-arg RUN_COMPOSER=true --build-arg BUILD_TAG_ARG=$BUILD_TAG"
           fi

      - docker build -t $ACCOUNT_ID.$ECR_PREFIX/hmpps/$DOCKER_IMAGE_TYPE:$BUILD_TAG --file $DOCKER_FILE $BUILD_ARGS . || exit 1
      - docker push $ACCOUNT_ID.$ECR_PREFIX/hmpps/$DOCKER_IMAGE_TYPE:$BUILD_TAG || exit 1

      #Build artisan latest when branch is master
      - BRANCH_NAME=$(cat branch_name.txt)
      - echo "BRANCH_NAME is $BRANCH_NAME"
      - |-
           if [ "$DOCKER_IMAGE_TYPE" = "artisan" ] && [ "$BRANCH_NAME" = "master" ]; then
             echo "Building artisan latest image"
             docker build -t $ACCOUNT_ID.$ECR_PREFIX/hmpps/$DOCKER_IMAGE_TYPE:latest --file $DOCKER_FILE $BUILD_ARGS . || exit 1
             docker push $ACCOUNT_ID.$ECR_PREFIX/hmpps/$DOCKER_IMAGE_TYPE:latest || exit 1
           fi
