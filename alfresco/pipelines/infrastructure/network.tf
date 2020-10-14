module "alfresco-dev-network" {
  source           = "../../modules/pipelines/dev/network"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "alf-network-build"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-network-terraform-alfresco"
  repo_branch      = "develop"
  environments     = ["alfresco-dev"]
  tags             = var.tags
  projects         = local.projects
}
