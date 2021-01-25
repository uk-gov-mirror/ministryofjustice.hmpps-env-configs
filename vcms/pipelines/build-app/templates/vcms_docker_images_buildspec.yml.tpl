---
version: 0.2
env:
  variables:
    ECR_PREFIX: "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps"
    BUILD_TAG: "latest"

phases:
  pre_build:
    commands:
      - $(aws ecr get-login --no-include-email --region eu-west-2)

  build:
    commands:
      #scality
      - DOCKER_PULL_IMAGE="scality/s3server:latest"
      - DOCKER_IMAGE_TYPE="scality-s3server"
      - echo "Building $DOCKER_IMAGE_TYPE"
      - docker pull $DOCKER_PULL_IMAGE                                                       || exit 1
      - docker tag $DOCKER_PULL_IMAGE $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG              || exit 1
      - docker push $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG                                || exit 1

      #php:7.4-apache-buster
      - DOCKER_PULL_IMAGE="php:7.4-apache-buster"
      - DOCKER_IMAGE_TYPE="php-7-4-apache-buster"
      - echo "Building $DOCKER_IMAGE_TYPE"
      - docker pull $DOCKER_PULL_IMAGE                                                       || exit 1
      - docker tag $DOCKER_PULL_IMAGE $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG              || exit 1
      - docker push $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG                                || exit 1

      #php:7.4-cli
      - DOCKER_PULL_IMAGE="php:7.4-cli"
      - DOCKER_IMAGE_TYPE="php-7-4-cli"
      - echo "Building $DOCKER_IMAGE_TYPE"
      - docker pull $DOCKER_PULL_IMAGE                                                       || exit 1
      - docker tag $DOCKER_PULL_IMAGE $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG              || exit 1
      - docker push $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG                                || exit 1

      #mariadb:latest
      - DOCKER_PULL_IMAGE="mariadb:latest"
      - DOCKER_IMAGE_TYPE="mariadb"
      - echo "Building $DOCKER_IMAGE_TYPE"
      - docker pull $DOCKER_PULL_IMAGE                                                       || exit 1
      - docker tag $DOCKER_PULL_IMAGE $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG              || exit 1
      - docker push $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG                                || exit 1

      #redis:latest
      - DOCKER_PULL_IMAGE="redis:latest"
      - DOCKER_IMAGE_TYPE="redis"
      - echo "Building $DOCKER_IMAGE_TYPE"
      - docker pull $DOCKER_PULL_IMAGE                                                       || exit 1
      - docker tag $DOCKER_PULL_IMAGE $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG              || exit 1
      - docker push $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG                                || exit 1

      #phpmyadmin/phpmyadmin
      - DOCKER_PULL_IMAGE="phpmyadmin/phpmyadmin"
      - DOCKER_IMAGE_TYPE="phpmyadmin"
      - echo "Building $DOCKER_IMAGE_TYPE"
      - docker pull $DOCKER_PULL_IMAGE                                                       || exit 1
      - docker tag $DOCKER_PULL_IMAGE $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG              || exit 1
      - docker push $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG                                || exit 1

      #node:14.15.4-buster
      - DOCKER_PULL_IMAGE="node:14.15.4-buster"
      - DOCKER_IMAGE_TYPE="node-14-15-4-buster"
      - echo "Building $DOCKER_IMAGE_TYPE"
      - docker pull $DOCKER_PULL_IMAGE                                                       || exit 1
      - docker tag $DOCKER_PULL_IMAGE $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG              || exit 1
      - docker push $ECR_PREFIX/$DOCKER_IMAGE_TYPE:$BUILD_TAG                                || exit 1
