module "target-envs" {
  source           = "../../modules/pipelines/restore_database"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-infra-versions"
  repo_branch      = "develop"
  environments = [
    "delius-stage",
    "delius-perf",
    "alfresco-dev"
  ]
  tags     = var.tags
  projects = local.projects
}
