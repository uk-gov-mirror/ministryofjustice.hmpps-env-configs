# common
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "aws-migration-pipelines/common/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "webhook" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "aws-migration-pipelines/eng-dev-webhook-events/terraform.tfstate"
    region = var.region
  }
}

data "aws_ssm_parameter" "webhook_secret" {
  name = "/codepipeline/webhooks/secret"
}
