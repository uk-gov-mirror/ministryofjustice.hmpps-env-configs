locals {
  name         = var.prefix
  apply_task   = var.approval_required ? "terraform_apply" : "apply"
}
