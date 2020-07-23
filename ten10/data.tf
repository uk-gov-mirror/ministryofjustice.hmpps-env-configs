# account id
data "aws_caller_identity" "current" {
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

# vpc
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

# vpc
data "terraform_remote_state" "ci_security_group" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "oracle-db-operation/security-groups-support-ci/terraform.tfstate"
    region = var.region
  }
}

