module "snapshot" {
  source           = "../../modules/snapshot"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-snapshot"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-mis-terraform-repo"
  repo_branch      = "master"
  environments     = ["mis-dev", "auto-test", "stage", "pre-prod", "prod"]
  tags             = var.tags
  projects         = local.projects
}
