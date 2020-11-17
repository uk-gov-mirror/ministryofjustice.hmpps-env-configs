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

variable "project_name" {
  type = string
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
    actions = map(string)
  }))
}
