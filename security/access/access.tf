module "delius_core_terraform" {
  source           = "./modules/pipeline"
  environment_name = "delius-core-dev"
  artefacts_bucket = local.artefacts_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  project_name     = "terraform-builds"
  log_group        = local.log_group_name
  tags             = local.tags
  github_repositories = {
    code = ["hmpps-security-access-terraform", "develop"]
  }
  stages = [
    {
      name = "Security"
      actions = {
        UserRoles = "user-roles"
      }
    }
  ]
}
