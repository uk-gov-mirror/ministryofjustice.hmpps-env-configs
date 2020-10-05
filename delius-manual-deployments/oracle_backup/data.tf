####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

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

# codebuild assume
data "template_file" "oracle_codebuild_role" {
  template = file("./templates/iam_assume_oracle_codebuild_role.tmpl")
  vars     = {}
}

# codebuild build role
data "template_file" "oracle_codebuild_iam_policy" {
  template = file("./templates/iam_oracle_codebuild_policy.tmpl")
  vars     = {}
}
