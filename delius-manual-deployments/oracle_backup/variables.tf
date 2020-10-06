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

variable "code_build" {
  type = map(string)
  default = {
    github_org          = "ministryofjustice"
    artifact_expiration = 90
    terraform_image     = "mojdigitalstudio/hmpps-terraform-builder-lite:latest"
    docker_image        = "mojdigitalstudio/hmpps-docker-compose"
    python_image        = "mojdigitalstudio/hmpps-ansible-builder-python-3"
    packer_image        = "mojdigitalstudio/hmpps-packer-builder:0.2.3"
    ansible_image       = "mojdigitalstudio/hmpps-ansible-builder"
  }
}

variable "oracle_backup_jobs" {
  description = "Object list of hosts in their respective environments to backup"
  type = list(object({ 
    environment = string
    host = string
    type = string
    schedule = string
  }))
  default = [
    {
      environment = "delius-core-dev"
      host = "delius_primarydb"
      type = "daily"
      schedule = "cron(30 05 ? * 3-6 *)"
    },
    {
      environment = "delius-core-dev"
      host = "delius_primarydb"
      type = "weekly"
      schedule = "cron(30 05 ? * 2 *)"
    },
    {
      environment = "delius-core-sandpit"
      host = "delius_primarydb"
      type = "daily"
      schedule = "cron(30 05 ? * 3-6 *)"
    },
    {
      environment = "delius-core-sandpit"
      host = "delius_primarydb"
      type = "weekly"
      schedule = "cron(30 05 ? * 2 *)"
    }
  ]
}

variable "oracle_validate_chunks_jobs" {
  description = "Object list of hosts in their respective environments to validate chuncks"
  type = list(object({ 
    environment = string
    host = string
  }))
  default = [
    {
      environment = "delius-core-dev"
      host = "delius_primarydb"
    },
    {
      environment = "delius-core-sandpit"
      host = "delius_primarydb"
    }
  ]
}

variable "oracle_validate_backup_jobs" {
  description = "Object list of hosts in their respective environments to validate backups"
  type = list(object({ 
    environment = string
    host = string
    schedule = string
  }))
  default = [
    {
      "environment": "delius-test",
      "host": "delius_standbydb1",
      "schedule": "cron(00 8 ? * 3 *)"
    },
    {
      "environment": "delius-core-sandpit",
      "host": "delius_primarydb",
      "schedule": "cron(46 13 ? * 2,4,6 *)"
    }
  ]
}