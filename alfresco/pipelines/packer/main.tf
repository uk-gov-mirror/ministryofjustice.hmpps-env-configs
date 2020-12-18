locals {
  github_repositories = {
    alfresco = ["hmpps-alfresco-packer", "develop"]
    solr     = ["hmpps-solr-packer", "develop"]
  }
  stages = [
    {
      name = "BuildAmi"
      actions = {
        AlfrescoAmi = "alfresco",
        SolrAmi     = "solr"
      }
    }
  ]
  prefix            = "alf-packer-builds"
  repo_owner        = "ministryofjustice"
  artefacts_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  log_group_name    = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  project_name      = "${local.prefix}-project"
  pipeline_name     = "${local.prefix}-pipeline"
  iam_role_arn      = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  packer_build_role = "${local.prefix}-role"
  compute_type      = "BUILD_GENERAL1_SMALL"
  type              = "LINUX_CONTAINER"
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.private-subnet-az3,
  ]
  tags = merge(
    data.terraform_remote_state.common.outputs.tags,
    {
      "Name" = local.prefix
    },
  )
  environment_variables = [
    {
      name  = "DEV_PIPELINE_NAME"
      value = "codepipeline/${local.pipeline_name}"
    },
    {
      name  = "INSTANCE_IAM_PROFILE",
      value = local.packer_build_role
    },
    {
      name  = "RPM_ARTIFACTS_BUCKET",
      value = "hmpps-eng-dev-alfresco-rpms"
    },
    {
      name  = "DEP_ARTIFACTS_BUCKET",
      value = "tf-eu-west-2-hmpps-eng-dev-config-s3bucket"
    }
  ]
  images = {
    python = var.code_build["python_image"]
    packer = var.code_build["packer_image"]
  }
}
