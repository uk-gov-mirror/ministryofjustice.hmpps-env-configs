locals {
  git_src_envs = [
    "alfresco-dev"
  ]
  protected_envs = [
    "delius-stage",
    "delius-pre-prod",
    "delius-prod"
  ]
  prefix                    = "alf-infra-build"
  release_prefix            = "alf-release"
  approval_notification_arn = data.terraform_remote_state.approvals.outputs.topic_arn
  artefacts_bucket          = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket           = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  cache_bucket              = data.terraform_remote_state.common.outputs.codebuild_info["build_cache_bucket"]
  iam_role_arn              = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  projects = {
    terraform = data.terraform_remote_state.base.outputs.projects["terraform"]
    ansible   = "hmpps-eng-builds-ansible3"
    python    = var.code_build["python_image"]
  }
  codebuild_projects = data.terraform_remote_state.common.outputs.codebuild_projects
  tags               = data.terraform_remote_state.common.outputs.tags
  log_group_name     = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  trigger_project    = "alfresco-infra-deploy-to-environments"
  release_repositories = {
    code  = ["hmpps-alfresco-infra-versions", "develop"]
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }
  pre_stages = [
    {
      name = "BuildPackages"
      actions = {
        TerraformPackage = ["build_tfpackage"]
      }
    }
  ]
  infra_stages = [
    {
      name = "Common"
      actions = {
        Common         = ["common"],
        SolrSnapShotID = ["ansible/ebs/param_store", "ansible", "hmpps-eng-builds-terraform-ansible"]
      }
    },
    {
      name = "Prereqs"
      actions = {
        AmiPermissions = ["ami_permissions"],
        S3buckets      = ["s3buckets"],
        IAM            = ["iam"],
        SecurityGroups = ["security-groups"],
      }
    },
    {
      name = "Storage"
      actions = {
        EFS        = ["efs"],
        Memchached = ["elasticache-memcached"],
      }
    },
    {
      name = "Databases"
      actions = {
        RDSDatabase = ["database"],
        ElkService  = ["elk-service"],
      }
    },
    {
      name = "Solr"
      actions = {
        SolrIndex = ["solr"],
      }
    },
    {
      name = "Alfresco"
      actions = {
        AlfrescoNodes   = ["asg"],
        AlfrescoTracker = ["tracker"],
      }
    },
    {
      name = "Support"
      actions = {
        EsAdmin             = ["es_admin"],
        WAF                 = ["waf"],
        CloudwatchExporter  = ["cloudwatch_exporter"],
        RestoreAlfrescoDocs = ["lambda/restoreDocs"],
        MonitoringAndAlerts = ["monitoring"],
      }
    }
  ]
  environment_variables = [
    {
      name  = "RELEASE_PKGS_PATH"
      type  = "PLAINTEXT"
      value = "projects"
    },
    {
      name  = "ENV_APPLY_OVERIDES"
      type  = "PLAINTEXT"
      value = "True"
    },
    {
      name  = "DEV_PIPELINE_NAME"
      type  = "PLAINTEXT"
      value = "codepipeline/alf-infra-build-alfresco-dev"
    }
  ]
  release_stages = [
    {
      name = "Prereqs"
      actions = {
        AmiPermissions = ["ami_permissions"],
        SolrSnapShotID = ["ansible/ebs/param_store", "ansible", "hmpps-eng-builds-terraform-ansible"]
      }
    },
    {
      name = "Solr"
      actions = {
        SolrIndex       = ["solr"],
        AlfrescoTracker = ["tracker"],
      }
    },
    {
      name = "Alfresco"
      actions = {
        AlfrescoNodes = ["asg"],
      }
    }
  ]
}
