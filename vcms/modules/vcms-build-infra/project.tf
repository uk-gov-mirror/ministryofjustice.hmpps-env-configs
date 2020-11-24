resource "aws_codebuild_webhook" "release" {
  project_name = aws_codebuild_project.release.name
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = "refs/heads/als-1941V2"
    }
  }
}
resource "aws_codebuild_project" "release" {
  name           = "${var.prefix}-package"
  description    = var.prefix
  build_timeout  = "15"
  queued_timeout = "30"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-package"
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
    name      = "vcms_terraform_code.zip"
    location  = var.code_build["artefacts_bucket"]
    path      = var.prefix
    packaging = "ZIP"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ansible-builder-python-3:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true
    environment_variable {
      name  = "ARTEFACTS_BUCKET"
      value = var.artefacts_bucket
    }
    environment_variable {
      name  = "GITHUB_REPO"
      value = var.repo_name
    }
    environment_variable {
      name  = "GITHUB_ORG"
      value = var.repo_owner
    }
    environment_variable {
      name  = "PACKAGE_NAME"
      value = "vcms-terraform.tar"
    }
  }
  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["infra_repo"]}"
    buildspec = templatefile("./templates/release_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}
