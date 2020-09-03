

#### Deployment

```bash
# set the AWS profile to eng-dev to get the SSM Parameter Store values
export AWS_PROFILE=hmpps_eng
# set other env vars
export ENVIRONMENT_NAME=dev;
# set env vars secrets
export GITHUB_TOKEN=$(aws ssm get-parameters --names /jenkins/github/accesstoken --region eu-west-2 --with-decrypt | jq -r '.Parameters[0].Value')
export TF_VAR_github_webhook_secret=$(aws ssm get-parameters --names /jenkins/github/github_webhook_secret/hmpps-base-packer --region eu-west-2 --with-decrypt | jq -r '.Parameters[0].Value')

# run a terraform plan docker container
# Note: run.sh has the params:
# - env (dev)
# - action (plan, apply, output, etc)
# - folder to plan, apply against
docker run -it  -v $(pwd):/home/tools/data -v ~/.aws:/home/tools/.aws -E ENVIRONMENT_NAME=$ENVIRONMENT_NAME -E AWS_PROFILE=$AWS_PROFILE -E RUNNING_IN_CONTAINER=True -E TF_VAR_github_webhook_secret=$TF_VAR_github_webhook_secret mojdigitalstudio/hmpps-terraform-builder-0-12 bash -c 'sh run.sh dev plan hmpps-engineering-tools'
