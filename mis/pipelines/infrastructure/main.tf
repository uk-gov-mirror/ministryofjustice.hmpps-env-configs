locals {
  dev_mis_db_ha_count         = data.aws_ssm_parameter.dev_mis_db_ha_count.value
  dev_misboe_db_ha_count      = data.aws_ssm_parameter.dev_misboe_db_ha_count.value
  dev_misdsd_db_ha_count      = data.aws_ssm_parameter.dev_misdsd_db_ha_count.value

  autotest_mis_db_ha_count    = data.aws_ssm_parameter.autotest_mis_db_ha_count.value
  autotest_misboe_db_ha_count = data.aws_ssm_parameter.autotest_misboe_db_ha_count.value
  autotest_misdsd_db_ha_count = data.aws_ssm_parameter.autotest_misdsd_db_ha_count.value

  stage_mis_db_ha_count       = data.aws_ssm_parameter.stage_mis_db_ha_count.value
  stage_misboe_db_ha_count    = data.aws_ssm_parameter.stage_misboe_db_ha_count.value
  stage_misdsd_db_ha_count    = data.aws_ssm_parameter.stage_misdsd_db_ha_count.value

  preprod_mis_db_ha_count       = data.aws_ssm_parameter.preprod_mis_db_ha_count.value
  preprod_misboe_db_ha_count    = data.aws_ssm_parameter.preprod_misboe_db_ha_count.value
  preprod_misdsd_db_ha_count    = data.aws_ssm_parameter.preprod_misdsd_db_ha_count.value

  prod_mis_db_ha_count       = data.aws_ssm_parameter.prod_mis_db_ha_count.value
  prod_misboe_db_ha_count    = data.aws_ssm_parameter.prod_misboe_db_ha_count.value
  prod_misdsd_db_ha_count    = data.aws_ssm_parameter.prod_misdsd_db_ha_count.value


  artefacts_bucket     = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  cache_bucket         = data.terraform_remote_state.common.outputs.codebuild_info["build_cache_bucket"]
  iam_role_arn         = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  codebuild_projects   = data.terraform_remote_state.common.outputs.codebuild_projects

  release_repositories = {
    utils = ["hmpps-engineering-pipelines-utils", "develop"]
  }

  environment_variables = [
    {
      name  = "RELEASE_PKGS_PATH"
      type  = "PLAINTEXT"
      value = "projects"
    },
    {
      name  = "DEV_PIPELINE_NAME"
      type  = "PLAINTEXT"
      value = "codepipeline/mis-infra-delius-mis-dev"
    },
    {
      name  = "VERSION_SSM_PATH"
      type  = "PLAINTEXT"
      value = "/versions/mis/repo/hmpps-mis-terraform-repo"
    }
  ]

  tags                 = data.terraform_remote_state.common.outputs.tags
  log_group_name       = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  prefix               = "mis-infra"
  release_prefix       = "mis-release"
  approval_notification_arn = data.terraform_remote_state.approvals.outputs.topic_arn

  package_project_name = local.codebuild_projects["terraform_package_ssm"]
  pre_stages = [
    {
      name = "BuildPackages"
      actions = {
        TerraformPackage   = ["build_tfpackage"]
      }
    }
  ]

  mis_dev_infra_stages = [
    {
      name = "Common"
      actions = {
        Common   = ["common"],
      }
    },
    {
      name = "S3buckets"
      actions = {
        S3buckets   = ["s3buckets"],
      }
    },
    {
      name = "Security"
      actions = {
        IAM            = ["iam"],
        SecurityGroups = ["security-groups"],
      }
    },
    {
      name = "MISDatabase"
      actions = merge(
        {
          MISPrimaryDB = ["database_mis"],
        },
        local.dev_mis_db_ha_count >= 1 ? { MISStandbyDB1 = ["database_mis_standbydb1"], } : {},
        local.dev_mis_db_ha_count >= 2 ? { MISStandbyDB2 = ["database_mis_standbydb2"], } : {},
       )
    },
    {
      name = "MisBoeDatabase"
      actions = merge(
        {
          MISBOEPrimaryDB = ["database_misboe"],
        },
        local.dev_misboe_db_ha_count >= 1 ? { MISBoeStandbyDB1 = ["database_misboe_standbydb1"], } : {},
        local.dev_misboe_db_ha_count >= 2 ? { MISBoeStandbyDB2 = ["database_misboe_standbydb2"], } : {},
       )
    },
    {
      name = "MisDsdDatabase"
      actions = merge(
        {
          MISDSDPrimaryDB = ["database_misdsd"],
        },
        local.dev_misdsd_db_ha_count >= 1 ? { MISDsdStandbyDB1 = ["database_misdsd_standbydb1"], } : {},
        local.dev_misdsd_db_ha_count >= 2 ? { MISDsdStandbyDB2 = ["database_misdsd_standbydb2"], } : {},
       )
    },
    {
      name = "ApplicationServers"
      actions = {
        ec2-ndl-dis   = ["ec2-ndl-dis"],
        ec2-ndl-bcs   = ["ec2-ndl-bcs"],
        ec2-ndl-bfs   = ["ec2-ndl-bfs"],
        ec2-ndl-bps   = ["ec2-ndl-bps"],
        ec2-ndl-bws   = ["ec2-ndl-bws"],
        Nextcloud     = ["nextcloud"],
      }
    },
    {
      name = "Monitoring"
      actions = {
        Monitoring   = ["monitoring"],
      }
    }
  ]

  autotest_infra_stages = [
    {
      name = "Common"
      actions = {
        Common   = ["common"],
      }
    },
    {
      name = "S3buckets"
      actions = {
        S3buckets   = ["s3buckets"],
      }
    },
    {
      name = "Security"
      actions = {
        IAM            = ["iam"],
        SecurityGroups = ["security-groups"],
      }
    },
    {
      name = "MISDatabase"
      actions = merge(
        {
          MISPrimaryDB = ["database_mis"],
        },
        local.autotest_mis_db_ha_count >= 1 ? { MISStandbyDB1 = ["database_mis_standbydb1"], } : {},
        local.autotest_mis_db_ha_count >= 2 ? { MISStandbyDB2 = ["database_mis_standbydb2"], } : {},
       )
    },
    {
      name = "MisBoeDatabase"
      actions = merge(
        {
          MISBOEPrimaryDB = ["database_misboe"],
        },
        local.autotest_misboe_db_ha_count >= 1 ? { MISBoeStandbyDB1 = ["database_misboe_standbydb1"], } : {},
        local.autotest_misboe_db_ha_count >= 2 ? { MISBoeStandbyDB2 = ["database_misboe_standbydb2"], } : {},
       )
    },
    {
      name = "MisDsdDatabase"
      actions = merge(
        {
          MISDSDPrimaryDB = ["database_misdsd"],
        },
        local.autotest_misdsd_db_ha_count >= 1 ? { MISDsdStandbyDB1 = ["database_misdsd_standbydb1"], } : {},
        local.autotest_misdsd_db_ha_count >= 2 ? { MISDsdStandbyDB2 = ["database_misdsd_standbydb2"], } : {},
       )
    },
    {
      name = "ApplicationServers"
      actions = {
        ec2-ndl-dis   = ["ec2-ndl-dis"],
        ec2-ndl-bcs   = ["ec2-ndl-bcs"],
        ec2-ndl-bfs   = ["ec2-ndl-bfs"],
        ec2-ndl-bps   = ["ec2-ndl-bps"],
        ec2-ndl-bws   = ["ec2-ndl-bws"],
        Nextcloud     = ["nextcloud"],
      }
    },
    {
      name = "Monitoring"
      actions = {
        Monitoring   = ["monitoring"],
      }
    }
  ]

  stage_infra_stages = [
    {
      name = "Common"
      actions = {
        Common   = ["common"],
      }
    },
    {
      name = "S3buckets"
      actions = {
        S3buckets   = ["s3buckets"],
      }
    },
    {
      name = "Security"
      actions = {
        IAM            = ["iam"],
        SecurityGroups = ["security-groups"],
      }
    },
    {
      name = "MISDatabase"
      actions = merge(
        {
          MISPrimaryDB = ["database_mis"],
        },
        local.stage_mis_db_ha_count >= 1 ? { MISStandbyDB1 = ["database_mis_standbydb1"], } : {},
        local.stage_mis_db_ha_count >= 2 ? { MISStandbyDB2 = ["database_mis_standbydb2"], } : {},
       )
    },
    {
      name = "MisBoeDatabase"
      actions = merge(
        {
          MISBOEPrimaryDB = ["database_misboe"],
        },
        local.stage_misboe_db_ha_count >= 1 ? { MISBoeStandbyDB1 = ["database_misboe_standbydb1"], } : {},
        local.stage_misboe_db_ha_count >= 2 ? { MISBoeStandbyDB2 = ["database_misboe_standbydb2"], } : {},
       )
    },
    {
      name = "MisDsdDatabase"
      actions = merge(
        {
          MISDSDPrimaryDB = ["database_misdsd"],
        },
        local.stage_misdsd_db_ha_count >= 1 ? { MISDsdStandbyDB1 = ["database_misdsd_standbydb1"], } : {},
        local.stage_misdsd_db_ha_count >= 2 ? { MISDsdStandbyDB2 = ["database_misdsd_standbydb2"], } : {},
       )
    },
    {
      name = "ApplicationServers"
      actions = {
        ec2-ndl-dis   = ["ec2-ndl-dis"],
        ec2-ndl-bcs   = ["ec2-ndl-bcs"],
        ec2-ndl-bfs   = ["ec2-ndl-bfs"],
        ec2-ndl-bps   = ["ec2-ndl-bps"],
        ec2-ndl-bws   = ["ec2-ndl-bws"],
        Nextcloud     = ["nextcloud"],
      }
    },
    {
      name = "Monitoring"
      actions = {
        Monitoring   = ["monitoring"],
      }
    }
  ]

  preprod_infra_stages = [
    {
      name = "Common"
      actions = {
        Common   = ["common"],
      }
    },
    {
      name = "S3buckets"
      actions = {
        S3buckets   = ["s3buckets"],
      }
    },
    {
      name = "Security"
      actions = {
        IAM            = ["iam"],
        SecurityGroups = ["security-groups"],
      }
    },
    {
      name = "MISDatabase"
      actions = merge(
        {
          MISPrimaryDB = ["database_mis"],
        },
        local.preprod_mis_db_ha_count >= 1 ? { MISStandbyDB1 = ["database_mis_standbydb1"], } : {},
        local.preprod_mis_db_ha_count >= 2 ? { MISStandbyDB2 = ["database_mis_standbydb2"], } : {},
       )
    },
    {
      name = "MisBoeDatabase"
      actions = merge(
        {
          MISBOEPrimaryDB = ["database_misboe"],
        },
        local.preprod_misboe_db_ha_count >= 1 ? { MISBoeStandbyDB1 = ["database_misboe_standbydb1"], } : {},
        local.preprod_misboe_db_ha_count >= 2 ? { MISBoeStandbyDB2 = ["database_misboe_standbydb2"], } : {},
       )
    },
    {
      name = "MisDsdDatabase"
      actions = merge(
        {
          MISDSDPrimaryDB = ["database_misdsd"],
        },
        local.preprod_misdsd_db_ha_count >= 1 ? { MISDsdStandbyDB1 = ["database_misdsd_standbydb1"], } : {},
        local.preprod_misdsd_db_ha_count >= 2 ? { MISDsdStandbyDB2 = ["database_misdsd_standbydb2"], } : {},
       )
    },
    {
      name = "ApplicationServers"
      actions = {
        ec2-ndl-dis   = ["ec2-ndl-dis"],
        ec2-ndl-bcs   = ["ec2-ndl-bcs"],
        ec2-ndl-bfs   = ["ec2-ndl-bfs"],
        ec2-ndl-bps   = ["ec2-ndl-bps"],
        ec2-ndl-bws   = ["ec2-ndl-bws"],
        Nextcloud     = ["nextcloud"],
      }
    },
    {
      name = "Monitoring"
      actions = {
        Monitoring   = ["monitoring"],
      }
    }
  ]

  prod_infra_stages = [
    {
      name = "Common"
      actions = {
        Common   = ["common"],
      }
    },
    {
      name = "S3buckets"
      actions = {
        S3buckets   = ["s3buckets"],
      }
    },
    {
      name = "Security"
      actions = {
        IAM            = ["iam"],
        SecurityGroups = ["security-groups"],
      }
    },
    {
      name = "MISDatabase"
      actions = merge(
        {
          MISPrimaryDB = ["database_mis"],
        },
        local.prod_mis_db_ha_count >= 1 ? { MISStandbyDB1 = ["database_mis_standbydb1"], } : {},
        local.prod_mis_db_ha_count >= 2 ? { MISStandbyDB2 = ["database_mis_standbydb2"], } : {},
       )
    },
    {
      name = "MisBoeDatabase"
      actions = merge(
        {
          MISBOEPrimaryDB = ["database_misboe"],
        },
        local.prod_misboe_db_ha_count >= 1 ? { MISBoeStandbyDB1 = ["database_misboe_standbydb1"], } : {},
        local.prod_misboe_db_ha_count >= 2 ? { MISBoeStandbyDB2 = ["database_misboe_standbydb2"], } : {},
       )
    },
    {
      name = "MisDsdDatabase"
      actions = merge(
        {
          MISDSDPrimaryDB = ["database_misdsd"],
        },
        local.prod_misdsd_db_ha_count >= 1 ? { MISDsdStandbyDB1 = ["database_misdsd_standbydb1"], } : {},
        local.prod_misdsd_db_ha_count >= 2 ? { MISDsdStandbyDB2 = ["database_misdsd_standbydb2"], } : {},
       )
    },
    {
      name = "ApplicationServers"
      actions = {
        ec2-ndl-dis   = ["ec2-ndl-dis"],
        ec2-ndl-bcs   = ["ec2-ndl-bcs"],
        ec2-ndl-bfs   = ["ec2-ndl-bfs"],
        ec2-ndl-bps   = ["ec2-ndl-bps"],
        ec2-ndl-bws   = ["ec2-ndl-bws"],
        Nextcloud     = ["nextcloud"],
      }
    },
    {
      name = "Monitoring"
      actions = {
        Monitoring   = ["monitoring"],
      }
    }
  ]
}
