variable "artefacts_bucket" {
  type = string
}
variable "pipeline_bucket" {
  type = string
}
variable "prefix" {
  type = string
}
variable "iam_role_arn" {
  type = string
}
variable "environments" {
  type    = list
  default = []
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

variable "projects" {
  type    = map(string)
  default = {}
}

variable "repo_owner" {
  type    = string
  default = "ministryofjustice"
}

variable "prod_target" {
  type    = string
  default = "no"
}
