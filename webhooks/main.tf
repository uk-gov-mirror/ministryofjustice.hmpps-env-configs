# Configure the GitHub Provider
provider "github" {
  owner = var.github_owner
}

locals {
  artefacts_bucket   = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket    = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn       = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  webhook_info       = data.terraform_remote_state.webhook.outputs.webhook_info
  webhook_secret_key = data.aws_ssm_parameter.webhook_secret.value
  tags               = data.terraform_remote_state.common.outputs.tags
}
