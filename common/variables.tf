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
    terraform_image     = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/terraform-builder-lite"
    ansible3_image      = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ansible-builder-python-3"
    ansible2_image      = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ansible-builder"
    packer_image        = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/packer-builder:0.33.0"
  }
}

