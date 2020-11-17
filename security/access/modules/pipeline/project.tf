resource "aws_codebuild_project" "project" {
  name           = local.project_name
  build_timeout  = "30"
  queued_timeout = "30"
  service_role   = var.iam_role_arn
  tags = merge(
    var.tags,
    {
      "Name" = local.project_name
    },
  )

  logs_config {
    cloudwatch_logs {
      group_name  = var.log_group
      stream_name = local.project_name
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/templates/buildspec.yml.tpl", {})
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.docker_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  }
}
