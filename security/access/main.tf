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
  codebuild_projects = data.terraform_remote_state.common.outputs.codebuild_projects
  stages = [
    {
      name = "Roles"
      actions = {
        UserRoles   = ["user-roles"],
        RemoteRoles = ["remote-roles"]
      }
    },
    {
      name = "SecurityLogging"
      actions = {
        SecLogging = ["sec-logging"]
      }
    },
    {
      name = "Services"
      actions = {
        GuardDuty = ["guardduty"],
        ConfigService = ["config-service"]
      }
    }
  ]
  pre_stages = [
    {
      name = "BuildPackages"
      actions = {
        TerraformPackage = ["build"]
      }
    }
  ]
  environment_variables = [
    {
      name  = "RELEASE_PKGS_PATH"
      type  = "PLAINTEXT"
      value = "projects"
    },
    {
      name  = "ENV_APPLY_OVERIDES"
      type  = "PLAINTEXT"
      value = "True"
    },
    {
      name  = "DEV_PIPELINE_NAME"
      type  = "PLAINTEXT"
      value = "codepipeline/security-access-alfresco-dev"
    }
  ]
}
