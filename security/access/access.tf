module "alfresco-dev" {
  source                = "../../modules/terraform-pipeline"
  environment_name      = "alf-dev"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "security-access-alfresco-dev"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_package_no_tag"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories = {
    code = ["hmpps-security-access-terraform", "main"]
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }
  stages = local.stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
  pipeline_approval_config = {
    CustomData      = "Please review plans and approve to proceed?"
    NotificationArn = ""
  }
}