####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################

locals {
  account_id   = data.aws_caller_identity.current.account_id
  region       = var.region
  tags         = var.tags
  compute_type = "BUILD_GENERAL1_SMALL"
  images = {
    terraform = "mojdigitalstudio/hmpps-aws-nuke:latest"
  }
  type         = "LINUX_CONTAINER"
  project_name = "aws-account-purge"
  build_spec   = "buildspec.yml"
}

