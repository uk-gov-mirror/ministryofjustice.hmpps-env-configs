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
    github_org = "ministryofjustice"
    infra_repo = "hmpps-delius-alfresco-shared-terraform"
    # jenkins_token_ssm   = "/jenkins/github/accesstoken"
    artifact_expiration = 90
    terraform_image     = "mojdigitalstudio/hmpps-terraform-builder-lite:latest"
    docker_image        = "mojdigitalstudio/hmpps-docker-compose"
    python_image        = "mojdigitalstudio/hmpps-ansible-builder-python-3"
    packer_image        = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/packer-builder:0.33.0"
  }
}

variable "github_webhook_secret" {
}