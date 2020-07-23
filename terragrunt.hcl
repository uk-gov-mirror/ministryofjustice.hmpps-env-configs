remote_state {
  backend = "s3"

  config = {
    encrypt = true
    bucket = "${get_env("TG_REMOTE_STATE_BUCKET", "REMOTE_STATE_BUCKET")}"
    key = "aws-migration-pipelines/${path_relative_to_include()}/terraform.tfstate"
    region = "${get_env("TG_REGION", "AWS-REGION")}"
    dynamodb_table = "${get_env("TG_ENVIRONMENT_IDENTIFIER", "ENVIRONMENT_IDENTIFIER")}-lock-table"
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = [
      "destroy",
      "plan",
      "import",
      "push",
      "refresh",
    ]

    arguments = [
      "-var-file=${get_parent_terragrunt_dir()}/env_configs/common.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_ENVIRONMENT", "ENVIRONMENT")}.tfvars",
    ]
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${get_env("TG_REGION", "AWS-REGION")}"
  version = "~> 2.65"
}
EOF
}