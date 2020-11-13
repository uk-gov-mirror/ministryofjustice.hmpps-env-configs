module "rds-restore" {
  source           = "../../modules/pipelines/restore_database"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-restore"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-infra-versions"
  repo_branch      = "develop"
  environments = [
    "delius-stage",
    "delius-perf",
    "alfresco-dev",
    "delius-pre-prod"
  ]
  tags     = local.tags
  projects = local.projects
}

module "rds-snapshots" {
  source           = "../../modules/pipelines/database_snapshot"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-snapshot"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-infra-versions"
  repo_branch      = "develop"
  environments = [
    "alfresco-dev",
    "delius-stage",
    "delius-perf",
    "delius-pre-prod"
  ]
  tags     = local.tags
  projects = local.projects
}

module "rds-snapshot-prod" {
  source           = "../../modules/pipelines/database_snapshot"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-snapshot"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-infra-versions"
  repo_branch      = "develop"
  environments = [
    "delius-prod"
  ]
  tags        = local.tags
  projects    = local.projects
  prod_target = "yes"
}
