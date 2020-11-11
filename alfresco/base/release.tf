resource "aws_codebuild_project" "release" {
  name           = local.release_project
  description    = local.release_project
  build_timeout  = "15"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags = merge(
    local.tags,
    {
      "Name" = local.release_project
    },
  )
  count = length(local.tasks_list)

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = local.release_project
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/ops-release-package.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["python"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true
  }
}

