variable "artefacts_bucket" {
  type = string
}
variable "prefix" {
  type = string
}
variable "iam_role_arn" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "code_build" {
  type    = map
}
