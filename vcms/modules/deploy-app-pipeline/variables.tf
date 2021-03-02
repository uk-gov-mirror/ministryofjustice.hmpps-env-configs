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
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "repo_owner" {
  type    = string
  default = "ministryofjustice"
}

variable "environment_type" {}

variable "account_id" {}

variable "prefix" {}

variable "test_stages" {
  default = []
}

variable "load_test_stages" {
  default = []
}
