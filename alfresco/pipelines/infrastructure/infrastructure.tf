module "alfresco-dev" {
  source           = "../../modules/pipelines/dev/git"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-delius-alfresco-shared-terraform"
  repo_branch      = "develop"
  environments     = ["alfresco-dev"]
  tags             = var.tags
  projects         = local.projects
}

module "integration-envs" {
  source           = "../../modules/pipelines/dev/s3"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-infra-versions"
  repo_branch      = "develop"
  environments     = ["delius-core-dev", "delius-int"]
  tags             = var.tags
  projects         = local.projects
}

module "protected-envs" {
  source           = "../../modules/pipelines/prompted/s3"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-infra-versions"
  repo_branch      = "develop"
  environments = [
    "delius-training-test",
    "delius-training",
    "delius-test",
    "delius-po-test1",
    "delius-stage",
    "delius-pre-prod",
    "delius-perf",
    "delius-prod"
  ]
  tags     = var.tags
  projects = local.projects
}
