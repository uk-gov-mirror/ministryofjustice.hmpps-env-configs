variable "name" {}

variable "schedule_expression" {}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "account_id" {}

variable "prefix" {}

variable "region" {}
