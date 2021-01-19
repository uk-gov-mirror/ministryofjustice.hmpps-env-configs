locals {
  artefacts_bucket    = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket     = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn        = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  prefix              = "vcms"
  account_id          = data.aws_caller_identity.current.account_id
  dev_account_id      = "356676313489"
  test_account_id     = "237599693891"
  perf_account_id     = "711258951176"
  stage_account_id    = "574159866058"
  preprod_account_id  = "486893912453"
  prod_account_id     = "823824448821"

  projects = {
    application    = data.terraform_remote_state.base.outputs.projects["application"]
  }

  vpc_id           = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.private-subnet-az3,
  ]

#Test dynamic stages
  test_stages = [
    {
      name = "smoke-tests"
    },
    {
      name = "regression-tests"
    },
    {
      name = "security-tests"
    }
  ]

  all_env_test_stages = [
    {
      name = "smoke-tests"
    }
  ]

  load_test_stages = [
    {
      name = "load-test-data"
    }
  ]
}
