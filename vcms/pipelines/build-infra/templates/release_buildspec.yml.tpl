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
      - git config --global advice.detachedHead false
  build:
    commands:
      - python utils/manage.py create-release -b main -sha $CODEBUILD_RESOLVED_SOURCE_VERSION
      - sleep 15
      - rm -rf builds
      - echo "REPO set to $GITHUB_REPO"
      - export PACKAGE_VERSION=$(python utils/manage.py get-version)
      - git clone -b $PACKAGE_VERSION https://$HMPPS_GITHUB_USER:$HMPPS_GITHUB_TOKEN@github.com/ministryofjustice/$GITHUB_REPO builds/
      - echo "export PACKAGE_VERSION=$PACKAGE_VERSION" > builds/output.txt
      - cat builds/output.txt
      - rm -rf builds/pipelines/*.yml
      - tar cf $PACKAGE_NAME builds
      - aws s3 cp --only-show-errors $PACKAGE_NAME s3://$ARTEFACTS_BUCKET/projects/vcms/infrastructure/$PACKAGE_VERSION/$PACKAGE_NAME
      - aws s3 cp --only-show-errors $PACKAGE_NAME s3://$ARTEFACTS_BUCKET/projects/vcms/infrastructure/latest/$PACKAGE_NAME
      - aws s3 cp --only-show-errors builds/output.txt s3://$ARTEFACTS_BUCKET/projects/vcms/infrastructure/$PACKAGE_VERSION/output.txt
      - aws s3 cp --only-show-errors builds/output.txt s3://$ARTEFACTS_BUCKET/projects/vcms/infrastructure/latest.txt
artifacts:
  base-directory: '$CODEBUILD_SRC_DIR'
  files:
    - '**/*'
