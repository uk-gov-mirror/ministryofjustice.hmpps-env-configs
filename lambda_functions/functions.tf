module "functions-pipeline" {
  source           = "./modules/lambda"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "eng-lambda"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-engineering-lambda-functions"
  repo_branch      = "develop"
  tags             = local.tags
}
