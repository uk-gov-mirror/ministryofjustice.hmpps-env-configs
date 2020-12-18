resource "aws_codebuild_project" "project" {
  name           = local.project_name
  description    = local.project_name
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout
  service_role   = local.iam_role_arn
  tags           = local.tags

  logs_config {
    cloudwatch_logs {
      group_name  = local.log_group_name
      stream_name = local.project_name
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["packer"]
    type                        = local.type
    privileged_mode             = true
    image_pull_credentials_type = "SERVICE_ROLE"
  }

  vpc_config {
    vpc_id  = local.vpc_id
    subnets = local.private_subnet_ids

    security_group_ids = [
      aws_security_group.packer.id,
    ]
  }
}
