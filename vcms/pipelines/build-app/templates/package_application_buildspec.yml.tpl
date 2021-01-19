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
      - docker build -t $ACCOUNT_ID.$ECR_PREFIX/hmpps/$DOCKER_IMAGE_TYPE:$BUILD_TAG --file $DOCKER_FILE $BUILD_ARGS . || exit 1
      - $(aws ecr get-login --no-include-email --region eu-west-2)
      - docker push $ACCOUNT_ID.$ECR_PREFIX/hmpps/$DOCKER_IMAGE_TYPE:$BUILD_TAG || exit 1
