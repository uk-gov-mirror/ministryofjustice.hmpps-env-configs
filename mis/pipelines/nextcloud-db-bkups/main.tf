locals {
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  prefix           = "nextcloud"
  account_id       = data.aws_caller_identity.current.account_id
  projects = {
    nextclouddb = data.terraform_remote_state.base.outputs.nextcloud-projects
  }
}
