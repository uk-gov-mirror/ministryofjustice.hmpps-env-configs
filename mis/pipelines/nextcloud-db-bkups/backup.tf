module "backup" {
  source           = "../../modules/nextcloud-db-backup"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-mis-terraform-repo"
  repo_branch      = "master"
  environments     = ["delius-mis-dev", "delius-auto-test", "delius-stage", "delius-pre-prod", "delius-prod"]
  tags             = var.tags
  projects         = local.projects
  task           = "db-backup"
}

module "restore" {
  source           = "../../modules/nextcloud-db-backup"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-mis-terraform-repo"
  repo_branch      = "master"
  environments     = ["delius-mis-dev", "delius-auto-test", "delius-stage", "delius-pre-prod", "delius-prod"]
  tags             = var.tags
  projects         = local.projects
  task             = "db-restore"
}
