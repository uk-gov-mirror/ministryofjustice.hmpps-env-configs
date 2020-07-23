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

variable "code_build" {
  type = map(string)
  default = {
    jenkins_token_ssm = "/jenkins/github/accesstoken"
    docker_image      = "aws/codebuild/standard:2.0"
    python_image      = "mojdigitalstudio/hmpps-ansible-builder-python-3"
  }
}

variable "ten10" {
  type = map(string)
  default = {
    common_name = "ten10"
  }
}

