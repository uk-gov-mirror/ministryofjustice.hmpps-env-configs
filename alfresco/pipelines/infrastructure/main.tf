locals {
  git_src_envs = [
    "alfresco-dev"
  ]
  protected_envs = [
    "delius-training-test",
    "delius-training",
    "delius-test",
    "delius-po-test1",
    "delius-stage",
    "delius-pre-prod",
    "delius-perf",
    "delius-prod"
  ]
  prefix           = "alf-infra-build"
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  projects = {
    terraform = data.terraform_remote_state.base.outputs.projects["terraform"]
    ansible   = "hmpps-eng-builds-ansible3"
  }
}
