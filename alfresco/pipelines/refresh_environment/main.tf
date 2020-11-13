locals {
  refresh_environments = [
    "delius-perf",
    "delius-stage",
    "alfresco-dev",
    "delius-pre-prod"
  ]
  prefix           = "alf-refresh-tasks"
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  projects = {
    terraform = data.terraform_remote_state.base.outputs.projects["terraform"]
    ansible   = "hmpps-eng-builds-ansible3"
  }
  tags = data.terraform_remote_state.common.outputs.tags
}
