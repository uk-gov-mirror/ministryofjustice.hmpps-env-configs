variable "tags" {
  type    = map(string)
  default = {}
}

variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "refresh_environments" {
  type = list
  default = [
    "delius-perf",
    "delius-stage"
  ]
}
