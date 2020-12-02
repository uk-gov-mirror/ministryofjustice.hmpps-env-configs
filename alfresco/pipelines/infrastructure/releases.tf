module "delius-po-test1-release" {
  source            = "../../../modules/terraform-pipeline"
  environment_name  = "delius-po-test1"
  approval_required = false
  artefacts_bucket  = local.artefacts_bucket
  prefix            = "${local.release_prefix}-delius-po-test1"
  iam_role_arn      = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group         = local.log_group_name
  tags              = local.tags
  cache_bucket      = local.cache_bucket
  github_repositories = local.release_repositories
  stages = local.release_stages
  pre_stages = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-test-release" {
  source            = "../../../modules/terraform-pipeline"
  environment_name  = "delius-test"
  approval_required = false
  artefacts_bucket  = local.artefacts_bucket
  prefix            = "${local.release_prefix}-delius-test"
  iam_role_arn      = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group         = local.log_group_name
  tags              = local.tags
  cache_bucket      = local.cache_bucket
  github_repositories = local.release_repositories
  stages = local.release_stages
  pre_stages = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-stage-release" {
  source            = "../../../modules/terraform-pipeline"
  environment_name  = "delius-stage"
  approval_required = true
  artefacts_bucket  = local.artefacts_bucket
  prefix            = "${local.release_prefix}-delius-stage"
  iam_role_arn      = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group         = local.log_group_name
  tags              = local.tags
  cache_bucket      = local.cache_bucket
  github_repositories = local.release_repositories
  stages = local.release_stages
  pre_stages = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-perf-release" {
  source            = "../../../modules/terraform-pipeline"
  environment_name  = "delius-perf"
  approval_required = false
  artefacts_bucket  = local.artefacts_bucket
  prefix            = "${local.release_prefix}-delius-perf"
  iam_role_arn      = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group         = local.log_group_name
  tags              = local.tags
  cache_bucket      = local.cache_bucket
  github_repositories = local.release_repositories
  stages = local.release_stages
  pre_stages = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-pre-prod-release" {
  source            = "../../../modules/terraform-pipeline"
  environment_name  = "delius-pre-prod"
  approval_required = true
  artefacts_bucket  = local.artefacts_bucket
  prefix            = "${local.release_prefix}-delius-pre-prod"
  iam_role_arn      = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group         = local.log_group_name
  tags              = local.tags
  cache_bucket      = local.cache_bucket
  github_repositories = local.release_repositories
  stages = local.release_stages
  pre_stages = local.pre_stages
  environment_variables = local.environment_variables
}

module "delius-prod-release" {
  source            = "../../../modules/terraform-pipeline"
  environment_name  = "delius-prod"
  approval_required = true
  artefacts_bucket  = local.artefacts_bucket
  prefix            = "${local.release_prefix}-delius-prod"
  iam_role_arn      = local.iam_role_arn
  package_project_name  = local.codebuild_projects["terraform_version"]
  tf_apply_project_name = local.codebuild_projects["terraform_apply"]
  tf_plan_project_name  = local.codebuild_projects["terraform_plan"]
  log_group         = local.log_group_name
  tags              = local.tags
  cache_bucket      = local.cache_bucket
  github_repositories = local.release_repositories
  stages = local.release_stages
  pre_stages = local.pre_stages
  environment_variables = local.environment_variables
}
