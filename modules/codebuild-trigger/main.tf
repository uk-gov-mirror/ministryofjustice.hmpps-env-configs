resource "aws_codebuild_webhook" "trigger" {
  project_name = aws_codebuild_project.trigger.name
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = var.pattern
    }
  }
}

resource "aws_codebuild_project" "trigger" {
  name           = var.name
  description    = var.description
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout 
  service_role   = var.service_role
  tags = var.tags

  logs_config {
    cloudwatch_logs {
      group_name  = var.log_group
      stream_name = var.name
    }
  }

  artifacts {
    type      = "S3"
    name      = "code.zip"
    location  = var.artefacts_bucket
    path      = var.name
    packaging = "ZIP"
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = var.build_type
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = var.privileged_mode
  }
  source {
    type      = "GITHUB"
    location  = var.location
    buildspec = var.buildspec

    auth {
      type     = "OAUTH"
      resource = var.oauth_token
    }
  }
}

