###Create docker images
resource "aws_codebuild_project" "docker-images" {
  name           = "${var.prefix}-docker-images"
  description    = "Transfer VCMS docker images to ECR"
  build_timeout  = "60"
  queued_timeout = "60"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-docker-images"
    },
  )
  logs_config {
    cloudwatch_logs {
      group_name  = var.code_build["log_group"]
      stream_name = var.prefix
    }
  }
  artifacts {
    type      = "S3"
    name      = "vcms_application_code.zip"
    location  = var.code_build["artefacts_bucket"]
    path      = var.prefix
    packaging = "ZIP"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "BUILD_TAG"
      value = "latest"
    }
  }
  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["app_repo"]}"
    buildspec = templatefile("./templates/vcms_docker_images_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}
