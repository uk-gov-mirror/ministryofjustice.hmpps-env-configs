locals {
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  prefix           = "vcms"
  projects = {
    buildinfra = data.terraform_remote_state.base.outputs.projects["buildinfra"]
    restoredb  = data.terraform_remote_state.base.outputs.projects["restoredb"]
  }

  smoke_test_stage = [
    {
      name = "smoke-tests"
    }
  ]

  nonprod_infra_stages = [
    {
      name = "network"
      actions = {
        network   = "network"
      }
    },
    {
      name = "SecurityComponents"
      actions = {
        Keys             = "keys"
        AcmAlerts        = "acm_alerts"
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

  prod_infra_stages = [
    {
      name = "network"
      actions = {
        network   = "network"
      }
    },
    {
      name = "SecurityComponents"
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
      }
    }
  ]
}
