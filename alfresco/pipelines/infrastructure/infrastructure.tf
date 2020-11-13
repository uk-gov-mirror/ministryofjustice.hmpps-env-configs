module "alfresco-dev" {
  source           = "../../modules/pipelines/dev/git"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = local.prefix
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-delius-alfresco-shared-terraform"
  repo_branch      = "develop"
  environments     = ["alfresco-dev"]
  tags             = local.tags
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
  environments     = ["delius-core-dev", "delius-int", "delius-auto-test"]
  tags             = local.tags
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
  environments     = local.protected_envs
  tags             = local.tags
  projects         = local.projects
}

module "release-pipeline" {
  source           = "../../modules/pipelines/releases"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "alf-release"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-infra-versions"
  repo_branch      = "develop"
  environments     = local.protected_envs
  tags             = local.tags
  projects         = local.projects
}
