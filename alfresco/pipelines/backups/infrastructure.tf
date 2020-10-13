module "backup-pipelines" {
  source           = "../../modules/pipelines/backups"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-delius-alfresco-shared-terraform"
  repo_branch      = "develop"
  environments = [
    # "delius-training-test",
    "delius-training",
    "delius-test",
    # "delius-po-test1",
    # "delius-stage",
    "delius-pre-prod",
    "delius-perf",
    # "delius-prod",
    "delius-core-dev",
    "delius-int",
    "alfresco-dev"
  ]
  tags     = var.tags
  projects = local.projects
}
