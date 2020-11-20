####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################

locals {
  account_id  = data.aws_caller_identity.current.account_id
  common_name = var.ten10["common_name"]
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.private-subnet-az3,
  ]
  region           = var.region
  tags             = data.terraform_remote_state.common.outputs.tags
  compute_type     = "BUILD_GENERAL1_SMALL"
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  images = {
    docker = var.code_build["docker_image"]
    python = var.code_build["python_image"]
  }
  type = "LINUX_CONTAINER"
  project_names = {
    handler = "${local.common_name}-task-handler"
  }
  project_list = [
    local.project_names["handler"],
  ]

  ecr_images = {
    test = "hmpps/${local.common_name}-serenity-tests"
  }

  ci_security_groups = [
    data.terraform_remote_state.ci_security_group.outputs.sg_map_ids["ci_delius_db"],
  ]

  tasks_list = [
    local.project_names["handler"],
  ]

  build_spec = "buildspec.yml"

  privileged_mode = true
}

