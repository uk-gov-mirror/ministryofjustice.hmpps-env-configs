---
version: 0.2

env:
  variables:
    RPM_ARTIFACTS_BUCKET: "hmpps-eng-dev-alfresco-rpms"
    DEP_ARTIFACTS_BUCKET: "tf-eu-west-2-hmpps-eng-dev-config-s3bucket"
    EC2_REGION: "eu-west-2"
    IAM_PROFILE_NAME: "${iam_profile_name}"
    TARGET_ENV: "dev"
  parameter-store:
    ALF_BUILD_PATH: "/codebuild/alfresco/packer/build/path" #UPDATE THIS SSM PARAM TO CHANGE THE VERSION

phases:
  pre_build:
    commands:
      - export BRANCH_NAME=$(python pipelines/get_branch.py)
      - echo "branch name is $BRANCH_NAME"
      - aws --region $EC2_REGION s3 cp s3://$RPM_ARTIFACTS_BUCKET/$ALF_BUILD_PATH/build.properties build.properties
  build:
    commands:
      - source build.properties
      - ansible-galaxy install -r ansible/requirements.yml; USER=`whoami` packer validate alfresco-pipeline.json
      - ansible-galaxy install -r ansible/requirements.yml; PACKER_VERSION=`packer --version` USER=`whoami` packer build alfresco-pipeline.json

