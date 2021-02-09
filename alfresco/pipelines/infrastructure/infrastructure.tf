module "alfresco-dev" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "alfresco-dev"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-alfresco-dev"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_package"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories = {
    code  = ["hmpps-delius-alfresco-shared-terraform", "develop"]
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
  pipeline_approval_config = {
    CustomData      = "Please review plans and approve to proceed?"
    NotificationArn = local.approval_notification_arn
  }
}

module "delius-core-dev" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-core-dev"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-core-dev"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories = {
    code  = ["hmpps-alfresco-infra-versions", "develop"]
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-int" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-int"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-int"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-auto-test" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-auto-test"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-auto-test"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-training-test" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-training-test"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-training-test"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-training" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-training"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-training"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-test" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-test"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-test"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-po-test1" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-po-test1"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-po-test1"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-perf" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-perf"
  approval_required     = false
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-perf"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-stage" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-stage"
  approval_required     = true
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-stage"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
  pipeline_approval_config = {
    CustomData      = "Please review plans and approve to proceed?"
    NotificationArn = local.approval_notification_arn
  }
}

module "delius-pre-prod" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-pre-prod"
  approval_required     = true
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-pre-prod"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
  pipeline_approval_config = {
    CustomData      = "Please review plans and approve to proceed?"
    NotificationArn = local.approval_notification_arn
  }
}

module "delius-prod" {
  source                = "../../../modules/terraform-pipeline"
  environment_name      = "delius-prod"
  approval_required     = true
  artefacts_bucket      = local.artefacts_bucket
  prefix                = "${local.prefix}-delius-prod"
  iam_role_arn          = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group             = local.log_group_name
  tags                  = local.tags
  cache_bucket          = local.cache_bucket
  github_repositories   = local.release_repositories
  stages                = local.infra_stages
  pre_stages            = local.pre_stages
  environment_variables = local.environment_variables
  pipeline_approval_config = {
    CustomData      = "Please review plans and approve to proceed?"
    NotificationArn = local.approval_notification_arn
  }
}
