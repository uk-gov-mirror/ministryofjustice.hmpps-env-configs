module "eng-dev-webhooks" {
  source                          = "./modules/eng-dev-webhooks"
  artifact_bucket                 = local.artefacts_bucket
  github_oauth_token_ssm_param    = local.github_oauth_token_ssm_param
  iam_role_codebuild              = local.iam_role_arn
  iam_role_codepipeline           = local.iam_role_arn
  name                            = local.name
  tags                            = var.tags
}
