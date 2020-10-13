module "secrets-pipeline" {
  source           = "../modules/credentials"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "security-create-credentials"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-env-configs"
  repo_branch      = "master"
  environments     = local.environments
  tags             = var.tags
  projects         = local.projects
}
