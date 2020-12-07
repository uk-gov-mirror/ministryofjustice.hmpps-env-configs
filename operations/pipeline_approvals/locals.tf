locals {
  common_name = "${var.prefix}-${var.environment}"
  tags             = data.terraform_remote_state.common.outputs.tags
}
