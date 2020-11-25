locals {
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  prefix           = "vcms"
  projects = {
    buildinfra = data.terraform_remote_state.base.outputs.projects["buildinfra"]
    restoredb  = data.terraform_remote_state.base.outputs.projects["restoredb"]
  }
}
