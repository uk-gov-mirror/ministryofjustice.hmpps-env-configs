variable "tags" {
  type    = map(string)
  default = {}
}

variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "build_timeout" {
  default     = 60
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed"
}

variable "queued_timeout" {
  default = 60
}

variable "code_build" {
  type = map(string)
  default = {
    github_org        = "ministryofjustice"
    jenkins_token_ssm = "/jenkins/github/accesstoken"
    python_image      = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ansible-builder-python-3:latest"
    packer_image      = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/packer-builder:0.33.0"
    ansible2_image    = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ansible-builder:latest"
  }
}
