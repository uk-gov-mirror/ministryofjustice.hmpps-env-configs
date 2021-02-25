variable "prefix" {
  type = string
}
variable "iam_role_arn" {
  type = string
}
variable "environments" {
  type    = list(any)
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

variable "pipeline_buckets" {
  type    = map(string)
  default = {}
}
