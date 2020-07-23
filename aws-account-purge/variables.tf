# RDS
variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "short_environment_identifier" {
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "alf_cloudwatch_log_retention" {
  default = 7
}

variable "aws_nuke_vars" {
  type = map(string)
  default = {
    build_timeout = "120"
    purge         = "False"
  }
}

variable "code_build" {
  type = map(string)
  default = {
    jenkins_token_ssm = "/jenkins/github/accesstoken"
  }
}

