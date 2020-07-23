####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################

locals {
  account_id  = data.aws_caller_identity.current.account_id
  common_name = "alfresco-build"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.private-subnet-az3,
  ]
  region          = var.region
  tags            = var.tags
  compute_type    = "BUILD_GENERAL1_SMALL"
  release_project = "alfresco-infra-release"
  images = {
    terraform = var.code_build["terraform_image"]
    docker    = var.code_build["docker_image"]
    python    = var.code_build["python_image"]
    packer    = var.code_build["packer_image"]
  }
  type = "LINUX_CONTAINER"
  project_names = {
    prepare       = "alfresco-prepare"
    refresh       = "alfresco-refresh"
    handler       = "alfresco-task-handler"
    terraform     = "alfresco-terraform"
  }
  project_list = [
    local.project_names["prepare"],
    local.project_names["refresh"],
    local.project_names["terraform"],
  ]

  tasks_list = [
    local.project_names["handler"],
  ]

  build_spec = "buildspec.yml"
}

