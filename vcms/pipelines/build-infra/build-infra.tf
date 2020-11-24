###Package
module "build-infra" {
  source           = "../../modules/vcms-build-infra"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infrastructure"
  iam_role_arn     = local.iam_role_arn
  repo_name        = "hmpps-vcms-terraform"
  repo_branch      = "master"
  environments     = ["dev"]
  tags             = var.tags
  projects         = local.projects

  code_build = {
      log_group         = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      iam_role_arn      = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
      artefacts_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
      jenkins_token_ssm = data.aws_ssm_parameter.jenkins_token.value
      github_org        = var.repo_owner
      infra_repo        = "hmpps-vcms-terraform"
  }
}


#------------------------------------------------------------
# Dev Environments
#------------------------------------------------------------
module "dev-only" {
  source           = "../../modules/infra-pipelines"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infra"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  environments     = ["dev"]

  github_repositories = {
    code = ["hmpps-vcms-terraform", "master"]
  }

  stages = [
    {
      name = "Network"
      actions = {
        Network   = "network"
      }
    },
    {
      name = "SecurityComponent"
      actions = {
        Keys             = "keys"
        SecurityGroups   = "security-groups"
      }
    },
    {
      name = "AppComponents"
      actions = {
        DocumentStore   = "document-store"
        Redis           = "redis"
        Database        = "database"
      }
    },
    {
      name = "Application"
      actions = {
        Application   = "application"
      }
    },
    {
      name = "MonitoringTestingComponents"
      actions = {
        Monitoring   = "monitoring"
        ConfigRules  = "config-rules"
        Loadrunner   = "loadrunner"
        AutoStart    = "auto-start"
        ChaosMonkey  = "testing/chaosmonkey"
      }
    }
  ]
}


#------------------------------------------------------------
# Test Environments
#------------------------------------------------------------
module "test-envs" {
  source           = "../../modules/infra-pipelines"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infra"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  environments     = ["test", "perf"]

  github_repositories = {
    code = ["hmpps-vcms-infra-versions", "main"]
  }

  stages = [
    {
      name = "Network"
      actions = {
        Network   = "network"
      }
    },
    {
      name = "SecurityComponent"
      actions = {
        Keys             = "keys"
        SecurityGroups   = "security-groups"
      }
    },
    {
      name = "AppComponents"
      actions = {
        DocumentStore   = "document-store"
        Redis           = "redis"
        Database        = "database"
      }
    },
    {
      name = "Application"
      actions = {
        Application   = "application"
      }
    },
    {
      name = "MonitoringTestingComponents"
      actions = {
        Monitoring   = "monitoring"
        ConfigRules  = "config-rules"
        Loadrunner   = "loadrunner"
        AutoStart    = "auto-start"
        ChaosMonkey  = "testing/chaosmonkey"
      }
    }
  ]
}

#------------------------------------------------------------
# Prod Environments
#------------------------------------------------------------
module "prod-environments" {
  source           = "../../modules/infra-pipelines-approve"
  artefacts_bucket = local.artefacts_bucket
  pipeline_bucket  = local.pipeline_bucket
  prefix           = "${local.prefix}-build-infra"
  iam_role_arn     = local.iam_role_arn
  tags             = var.tags
  projects         = local.projects
  environments     = ["stage", "preprod", "prod"]

  github_repositories = {
    code = ["hmpps-vcms-infra-versions", "main"]
  }

  stages = [
    {
      name = "Network"
      actions = {
        network   = "network"
      }
    },
    {
      name = "Keys"
      actions = {
        Keys  = "keys"
      }
    },
    {
      name = "SecurityGroups"
      actions = {
        SecurityGroups = "security-groups"
      }
    },
    {
      name = "DocumentStore"
      actions = {
        DocumentStore = "document-store"
      }
    },
    {
      name = "Redis"
      actions = {
        Redis = "redis"
      }
    },
    {
      name = "Database"
      actions = {
        Database = "database"
      }
    },
    {
      name = "Application"
      actions = {
        Application = "application"
      }
    },
    {
      name = "ConfigRules"
      actions = {
        ConfigRules = "config-rules"
      }
    },
    {
      name = "Loadrunner"
      actions = {
        Loadrunner = "loadrunner"
      }
    },
    {
      name = "ChaosMonkey"
      actions = {
        ChaosMonkey = "testing/chaosmonkey"
      }
    },
    {
      name = "AutoStart"
      actions = {
        AutoStart = "auto-start"
      }
    },
    {
      name = "Monitoring"
      actions = {
        Monitoring = "monitoring"
      }
    }
  ]
}
