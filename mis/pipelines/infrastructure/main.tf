locals {
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
  infra_stages = [
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
