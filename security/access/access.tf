module "security-access-terraform" {
  source            = "../../modules/terraform-pipeline"
  environment_name  = "hmpps-sandpit"
  approval_required = false
  artefacts_bucket  = local.artefacts_bucket
  prefix            = "${local.prefix}-terraform-components"
  iam_role_arn      = local.iam_role_arn
  project_name      = local.projects["terraform_utils"]
  log_group         = local.log_group_name
  tags              = local.tags
  cache_bucket      = local.cache_bucket
  github_repositories = {
    code = ["hmpps-security-access-terraform", "main"]
  }
  stages = [
    {
      name = "Roles"
      actions = {
        UserRoles   = "user-roles",
        RemoteRoles = "remote-roles"
      }
    },
    {
      name = "SecurityLogging"
      actions = {
        SecLogging = "sec-logging"
      }
    },
    {
      name = "Services"
      actions = {
        GuardDuty = "guardduty"
        ConfigService = "config-service"
      }
    }
  ]
}

