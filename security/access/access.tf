module "security-access-terraform" {
  source           = "./modules/pipeline"
  environment_name = "hmpps-sandpit"
  artefacts_bucket = local.artefacts_bucket
  prefix           = "${local.prefix}-terraform-components"
  iam_role_arn     = local.iam_role_arn
  project_name     = "terraform-builds"
  log_group        = local.log_group_name
  tags             = local.tags
  cache_bucket     = local.cache_bucket
  github_repositories = {
    code = ["hmpps-security-access-terraform", "patch/tf-upgrade"]
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
      name = "ConfigService"
      actions = {
        ConfigService = "config-service",
      }
    },
    {
      name = "SecurityLogging"
      actions = {
        SecLogging = "sec-logging"
      }
    },
    {
      name = "GuardDuty"
      actions = {
        GuardDuty = "guardduty"
      }
    }
  ]
}
