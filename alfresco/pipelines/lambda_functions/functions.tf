module "release-pipeline" {
  source           = "../../modules/pipelines/lambda"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "alf-lambda"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-alfresco-lambda-functions"
  repo_branch      = "develop"
  tags             = var.tags
}
