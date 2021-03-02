variable "pipeline_bucket" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "repo_name" {
  type = string
}

variable "repo_branch" {
  type    = string
  default = "develop"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "repo_owner" {
  type    = string
  default = "ministryofjustice"
}

variable "account_id" {}
