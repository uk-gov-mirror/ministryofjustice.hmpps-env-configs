variable "environment_name" {
  type = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role that enables AWS CodePipeline to interact with the required AWS services."
  type        = string
}

variable "github_repositories" {
  type = map(list(string))
}

variable "repo_owner" {
  default = "ministryofjustice"
  type    = string
}

variable "artefacts_bucket" {
  description = "Name of the S3 bucket to use for storing build and pipeline artifacts."
  type        = string
}

variable "tags" {
  type = map(string)
}

variable "package_project_name" {
  default     = "hmpps-eng-builds-terraform-package"
}

variable "tf_plan_project_name" {
  default     = "hmpps-eng-builds-terraform-plan"
}

variable "tf_apply_project_name" {
  default     = "hmpps-eng-builds-terraform-apply"
}

variable "prefix" {
  type    = string
  default = "security-access"
}

variable "log_group" {
  type = string
}

variable "docker_image" {
  type    = string
  default = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/terraform-builder-lite:latest"
}

variable "stages" {
  type = list(object({
    name    = string
    actions = map(list(string))
  }))
}

variable "pipeline_approval_config" {
  type = map(string)
  default = {
    CustomData = "Please review plans and approve to proceed?"
  }
}

variable "cache_bucket" {
  type    = string
}

variable "approval_required" {
  description = "Whether the Terraform planned changes must be approved before applying."
  default     = true
}
