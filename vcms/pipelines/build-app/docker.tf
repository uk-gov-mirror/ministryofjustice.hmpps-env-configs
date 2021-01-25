###build docker builder project
module "docker-image-projects" {
  source           = "../../modules/vcms-docker-images"
  artefacts_bucket = local.artefacts_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags

  code_build = {
      log_group         = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      iam_role_arn      = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
      artefacts_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
      jenkins_token_ssm = data.aws_ssm_parameter.jenkins_token.value
      github_org        = var.repo_owner
      app_repo          = "hmpps-vcms-infra-versions"
  }
}
