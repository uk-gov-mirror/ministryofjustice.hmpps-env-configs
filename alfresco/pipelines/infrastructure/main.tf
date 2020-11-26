locals {
  git_src_envs = [
    "alfresco-dev"
  ]
  protected_envs = [
    "delius-training-test",
    "delius-training",
    "delius-test",
    "delius-po-test1",
    "delius-stage",
    "delius-pre-prod",
    "delius-perf",
    "delius-prod"
  ]
  prefix           = "alf-infra-build"
  artefacts_bucket = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket  = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  cache_bucket     = data.terraform_remote_state.common.outputs.codebuild_info["build_cache_bucket"]
  iam_role_arn     = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  projects = {
    terraform = data.terraform_remote_state.base.outputs.projects["terraform"]
    ansible   = "hmpps-eng-builds-ansible3"
  }
  codebuild_projects = data.terraform_remote_state.common.outputs.codebuild_projects
  tags               = data.terraform_remote_state.common.outputs.tags
  log_group_name     = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  pre_stages = [
    {
      name = "BuildPackages"
      actions = {
        TerraformPackage   = ["build_tfpackage"]
      }
    }
  ]
  infra_stages = [
    {
      name = "Common"
      actions = {
        Common   = ["common"],
        SolrSnapShotID   = ["ansible/ebs/param_store", "ansible", "hmpps-eng-builds-terraform-ansible"]
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
        EFS = ["efs"],
        Memchached = ["elasticache-memcached"],
      }
    },
    {
      name = "Databases"
      actions = {
        RDSDatabase = ["database"],
        ElkService = ["elk-service"],
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
        AlfrescoNodes = ["asg"],
      }
    },
    {
      name = "Support"
      actions = {
        EsAdmin = ["es_admin"],
        WAF = ["waf"],
        CloudwatchExporter = ["cloudwatch_exporter"],
        RestoreAlfrescoDocs = ["lambda/restoreDocs"],
        MonitoringAndAlerts = ["monitoring"],
      }
    }
  ] 
}
