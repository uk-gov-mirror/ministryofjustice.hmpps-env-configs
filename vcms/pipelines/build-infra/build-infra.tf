###Package
module "build-infra" {
  source           = "../../modules/vcms-build-infra"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infrastructure"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-terraform"
  repo_branch      = "master"
  environments     = ["dev"]
  tags             = var.tags
  projects         = local.projects

  code_build = {
      log_group         = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      iam_role_arn      = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
      artefacts_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
      jenkins_token_ssm = data.aws_ssm_parameter.jenkins_token.value
      github_org        = var.repo_owner
      infra_repo        = "hmpps-vcms-terraform"
  }
}


#------------------------------------------------------------
# Dev Environments
#------------------------------------------------------------
module "dev-only" {
  source           = "../../modules/infra-pipelines"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infra"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  environments     = ["dev"]
  test_stages      = local.smoke_test_stage

  github_repositories = {
    code = ["hmpps-vcms-terraform", "master"]
  }

  stages = local.nonprod_infra_stages
}


#------------------------------------------------------------
# Test Environments
#------------------------------------------------------------
module "test-environments" {
  source           = "../../modules/infra-pipelines"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infra"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  environments     = ["test", "perf", "stage"]
  test_stages      = local.smoke_test_stage

  github_repositories = {
    code = ["hmpps-vcms-infra-versions", "main"]
  }

  stages = local.nonprod_infra_stages
}

#------------------------------------------------------------
# Non-Prod Environments
#------------------------------------------------------------
module "non-prod-environments" {
  source           = "../../modules/infra-pipelines-approve"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infra"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  environments     = ["preprod"]

  github_repositories = {
    code = ["hmpps-vcms-infra-versions", "main"]
  }

  stages = local.nonprod_infra_stages
}


#------------------------------------------------------------
# Prod Environments
#------------------------------------------------------------
module "prod-environments" {
  source           = "../../modules/infra-pipelines-approve"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infra"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  environments     = ["prod"]

  github_repositories = {
    code = ["hmpps-vcms-infra-versions", "main"]
  }

  stages = local.prod_infra_stages
}

#------------------------------------------------------------
# DB Restore pipeline
#------------------------------------------------------------
module "db-restore" {
  source           = "../../modules/restore-db"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-restore-db"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  repo_name        = "hmpps-vcms-infra-versions"
  repo_branch      = "main"
  environments     = ["dev", "test", "perf", "stage", "preprod", "prod"]
}
