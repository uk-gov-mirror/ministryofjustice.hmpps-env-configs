####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################

locals {
  account_id  = data.aws_caller_identity.current.account_id
  common_name = "mis-build"
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
    terraform = "mojdigitalstudio/hmpps-terraform-builder-0-11-14:"
  }
  type = "LINUX_CONTAINER"
  project_names = {
    terraform      = "mis-terraform"
    snapshot      =  "mis-snapshot"
  }
  project_list = [
    local.project_names["terraform"],
    local.project_names["snapshot"],
  ]

  build_spec = "buildspec.yml"
}
