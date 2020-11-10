#### Pre-requisites

```bash
export ENVIRONMENT_NAME=hmpps_eng; 
export AWS_PROFILE=hmpps_eng; 
export  RUNNING_IN_CONTAINER=True;
export GITHUB_TOKEN=$(aws ssm get-parameters --names /jenkins/github/accesstoken --with-decryption --region eu-west-2 | jq -r '.Parameters[0].Value')
export TF_VAR_github_webhook_secret=$(aws ssm get-parameters --names /jenkins/github/github_webhook_secret/hmpps-base-packer --with-decryption --region eu-west-2 | jq -r '.Parameters[0].Value')

export AWS_PROFILE=hmpps_token;
```

#### Running a plan
```bash
docker run -it  -v $(pwd):/home/tools/data -v ~/.aws:/home/tools/.aws -e ENVIRONMENT_NAME=$ENVIRONMENT_NAME -e AWS_PROFILE=$AWS_PROFILE -e RUNNING_IN_CONTAINER=True -e TF_VAR_github_webhook_secret=$TF_VAR_github_webhook_secret -e GITHUB_TOKEN=$GITHUB_TOKEN mojdigitalstudio/hmpps-terraform-builder-0-12 bash -c 'sh run.sh dev plan hmpps-engineering-tools'
```