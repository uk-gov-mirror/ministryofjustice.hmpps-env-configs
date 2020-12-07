module "delius-mis-dev" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-mis-dev"
  approval_required     = true
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-mis-dev"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.package_project_name
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories = {
    code = ["hmpps-mis-terraform-repo", "als-1942"]
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }
  stages     = local.infra_stages
  pre_stages = local.pre_stages
}
