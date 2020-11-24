####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################

locals {
  account_id  = data.aws_caller_identity.current.account_id
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.private-subnet-az3,
  ]
  region          = var.region
  tags            = var.tags
  compute_type    = "BUILD_GENERAL1_SMALL"
  images = {
    terraform = var.code_build["terraform_image"]
  }
  type = "LINUX_CONTAINER"
  project_names = {
    buildinfra     = "vcms-build-infra"
    application    = "vcms-application"
  }
  project_list = [
    local.project_names["buildinfra"],
    local.project_names["application"],
  ]

  build_spec = "buildspec.yml"
}
