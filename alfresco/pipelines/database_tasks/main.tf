locals {
  prefix           = "alf-database"
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  cache_bucket     = data.terraform_remote_state.common.outputs.codebuild_info["build_cache_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  projects = {
    apply   = data.terraform_remote_state.common.outputs.codebuild_projects["terraform_apply"]
    plan    = data.terraform_remote_state.common.outputs.codebuild_projects["terraform_plan"]
    ansible = "hmpps-eng-builds-terraform-ansible"
    version = data.terraform_remote_state.common.outputs.codebuild_projects["terraform_version"]
  }
  tags = data.terraform_remote_state.common.outputs.tags
}
