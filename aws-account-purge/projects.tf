# dev
resource "aws_codebuild_project" "projects" {
  name           = local.project_name
  description    = local.project_name
  build_timeout  = var.aws_nuke_vars["build_timeout"]
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags = merge(
    local.tags,
    {
      "Name" = local.project_name
    },
  )

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = local.project_name
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  environment {
    compute_type = local.compute_type
    image        = local.images["terraform"]
    type         = local.type

    environment_variable {
      name  = "PURGE"
      value = var.aws_nuke_vars["purge"]
    }
  }
}

