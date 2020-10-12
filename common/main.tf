####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################

locals {
  prefix       = "${var.business_unit}-${var.project}"
  common_name  = "${local.prefix}-builds"
  account_id   = data.aws_caller_identity.current.account_id
  region       = var.region
  tags         = var.tags
  compute_type = "BUILD_GENERAL1_SMALL"
  images = {
    terraform = var.code_build["terraform_image"]
    ansible3  = var.code_build["ansible3_image"]
    ansible2  = var.code_build["ansible2_image"]
    packer    = var.code_build["packer_image"]
  }
  type = "LINUX_CONTAINER"
}

