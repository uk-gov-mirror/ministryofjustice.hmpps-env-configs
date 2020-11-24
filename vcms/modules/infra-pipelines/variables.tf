
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

variable "stages" {
  type = list(object({
    name    = string
    actions = map(string)
  }))
}

variable "github_repositories" {
  type = map(list(string))
}
