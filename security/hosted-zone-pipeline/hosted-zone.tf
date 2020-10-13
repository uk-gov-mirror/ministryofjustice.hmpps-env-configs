module "zones-pipeline" {
  source           = "../modules/hosted_zone"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "security-hosted-zones"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-ansible-playbooks"
  repo_branch      = "master"
  environments     = local.environments
  tags             = var.tags
  projects         = local.projects
}
