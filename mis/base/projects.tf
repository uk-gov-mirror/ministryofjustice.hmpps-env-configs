# dev
resource "aws_codebuild_project" "projects" {
  name           = local.project_list[count.index]
  description    = local.project_list[count.index]
  build_timeout  = "45"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags = merge(
    local.tags,
    {
      "Name" = local.project_list[count.index]
    },
  )
  count = length(local.project_list)

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = local.project_list[count.index]
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec-${local.project_list[count.index]}.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["terraform"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  }
}

# Nextcloud DB Backup/Restore
resource "aws_codebuild_project" "nextcloud-db" {
  name           = local.nextcloud_db_project
  description    = local.nextcloud_db_project
  build_timeout  = "45"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags = merge(
    local.tags,
    {
      "Name" = local.nextcloud_db_project
    },
  )

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = local.nextcloud_db_project
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec-${local.nextcloud_db_project}.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["mysql"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  }
  vpc_config {
    vpc_id  = local.vpc_id
    subnets = local.private_subnet_ids

    security_group_ids = [
      aws_security_group.mis.id,
    ]
  }
}
