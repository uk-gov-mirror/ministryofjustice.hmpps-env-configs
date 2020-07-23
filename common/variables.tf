# RDS
variable "region" {
}

variable "business_unit" {
}

variable "project" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
}

variable "short_environment_identifier" {
}


variable "environment" {
}


variable "tags" {
  type    = map(string)
  default = {}
}

variable "cloudwatch_log_retention" {
  default = 7
}

variable "code_build" {
  type = map(string)
  default = {
    github_org          = "ministryofjustice"
    jenkins_token_ssm   = "/jenkins/github/accesstoken"
    artifact_expiration = 180
    terraform_image     = "mojdigitalstudio/hmpps-terraform-builder-0-12"
    ansible3_image      = "mojdigitalstudio/hmpps-ansible-builder-python-3"
    packer_image        = "mojdigitalstudio/hmpps-packer-builder"
  }
}

