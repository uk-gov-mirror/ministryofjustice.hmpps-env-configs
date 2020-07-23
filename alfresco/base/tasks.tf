resource "aws_codebuild_project" "tasks" {
  name           = local.tasks_list[count.index]
  description    = local.tasks_list[count.index]
  build_timeout  = local.tasks_list[count.index] == "alfresco-elasticsearch" ? 480 : 45
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags = merge(
    local.tags,
    {
      "Name" = local.tasks_list[count.index]
    },
  )
  count = length(local.tasks_list)

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = local.tasks_list[count.index]
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/ops-${local.tasks_list[count.index]}.yml"
  }

  environment {
    compute_type    = local.compute_type
    image           = local.images["docker"]
    type            = local.type
    privileged_mode = true

    environment_variable {
      name  = "DOCKER_CERTS_DIR"
      value = "/opt/docker"
    }
  }
  vpc_config {
    vpc_id = local.vpc_id
    subnets = local.private_subnet_ids

    security_group_ids = [
      aws_security_group.alfresco.id,
    ]
  }
}

