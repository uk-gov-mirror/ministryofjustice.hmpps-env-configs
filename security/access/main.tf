####################################################
# Locals
####################################################

locals {
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  cache_bucket     = data.terraform_remote_state.common.outputs.codebuild_info["build_cache_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  log_group_name   = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  tags             = data.terraform_remote_state.common.outputs.tags
  prefix           = "security-access"
  projects         = data.terraform_remote_state.common.outputs.codebuild_projects
}
