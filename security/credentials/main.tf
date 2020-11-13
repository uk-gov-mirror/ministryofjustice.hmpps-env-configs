####################################################
# Locals
####################################################

locals {
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  projects = {
    ansible2 = "hmpps-eng-builds-ansible2"
  }
  environments = ["alfresco-dev"]
  tags         = data.terraform_remote_state.common.outputs.tags
}
