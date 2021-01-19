module "deploy-app-projects" {
  source              = "../../modules/deploy-app"
  artefacts_bucket    = local.artefacts_bucket
  prefix              = "${local.prefix}"
  iam_role_arn        = local.iam_role_arn
  tags                = var.tags
  vpc_id              = local.vpc_id
  private_subnet_ids  = local.private_subnet_ids

  code_build = {
      log_group         = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      iam_role_arn      = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
      artefacts_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
      jenkins_token_ssm = data.aws_ssm_parameter.jenkins_token.value
      github_org        = var.repo_owner
      app_repo          = "hmpps-vcms-infra-versions"
  }
}

###Deploy Application Pipeline
module "dev-deploy-app-pipeline" {
  source           = "../../modules/deploy-app-pipeline"
  pipeline_bucket  = local.pipeline_bucket
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-infra-versions"
  repo_branch      = "main"
  tags             = var.tags
  environment_type = "dev"
  account_id       = local.dev_account_id
  prefix           = local.prefix
  test_stages      = local.all_env_test_stages
}

module "test-deploy-app-pipeline" {
  source           = "../../modules/deploy-app-pipeline"
  pipeline_bucket  = local.pipeline_bucket
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-infra-versions"
  repo_branch      = "main"
  tags             = var.tags
  environment_type = "test"
  account_id       = local.test_account_id
  prefix           = local.prefix
  test_stages      = local.test_stages
  load_test_stages = local.load_test_stages
}

module "perf-deploy-app-pipeline" {
  source           = "../../modules/deploy-app-pipeline"
  pipeline_bucket  = local.pipeline_bucket
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-infra-versions"
  repo_branch      = "main"
  tags             = var.tags
  environment_type = "perf"
  account_id       = local.perf_account_id
  prefix           = local.prefix
  test_stages      = local.all_env_test_stages
}

module "stage-deploy-app-pipeline" {
  source           = "../../modules/deploy-app-pipeline"
  pipeline_bucket  = local.pipeline_bucket
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-infra-versions"
  repo_branch      = "main"
  tags             = var.tags
  environment_type = "stage"
  account_id       = local.stage_account_id
  prefix           = local.prefix
  test_stages      = local.all_env_test_stages
}

module "preprod-deploy-app-pipeline" {
  source           = "../../modules/deploy-app-pipeline"
  pipeline_bucket  = local.pipeline_bucket
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-infra-versions"
  repo_branch      = "main"
  tags             = var.tags
  environment_type = "preprod"
  account_id       = local.preprod_account_id
  prefix           = local.prefix
}

module "prod-deploy-app-pipeline" {
  source           = "../../modules/deploy-app-pipeline"
  pipeline_bucket  = local.pipeline_bucket
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-infra-versions"
  repo_branch      = "main"
  tags             = var.tags
  environment_type = "prod"
  account_id       = local.prod_account_id
  prefix           = local.prefix
}
