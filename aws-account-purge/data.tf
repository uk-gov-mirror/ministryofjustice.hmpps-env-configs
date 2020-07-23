# account id
data "aws_caller_identity" "current" {
}

# ssm
data "aws_ssm_parameter" "jenkins_token" {
  name = var.code_build["jenkins_token_ssm"]
}

# common
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "aws-migration-pipelines/common/terraform.tfstate"
    region = var.region
  }
}

