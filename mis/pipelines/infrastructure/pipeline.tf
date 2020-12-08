module "delius-mis-dev" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-mis-dev"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-mis-dev"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_package_ssm"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories = {
    code = ["hmpps-mis-terraform-repo", "master"]
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }
  stages                   = local.infra_stages
  pre_stages               = local.pre_stages
  environment_variables    = local.environment_variables
  pipeline_approval_config = {
    CustomData      = "Please review plans and approve to proceed?"
    NotificationArn = local.approval_notification_arn
  }
}


module "delius-auto-test" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-auto-test"
  approval_required     = true
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-auto-test"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version_ssm"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories = {
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }
  stages                   = local.infra_stages
  pre_stages               = local.pre_stages
  environment_variables    = local.environment_variables
  pipeline_approval_config = {
    CustomData      = "Please review plans and approve to proceed?"
    NotificationArn = local.approval_notification_arn
  }
}
