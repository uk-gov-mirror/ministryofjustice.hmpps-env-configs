resource "aws_codebuild_webhook" "release" {
  project_name = aws_codebuild_project.release.name
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = "refs/heads/develop"
    }
  }
}

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

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = local.release_project
    }
  }

  artifacts {
    type      = "S3"
    name      = "alfresco_terraform_code.zip"
    location  = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
    path      = local.release_project
    packaging = "ZIP"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["python"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true
    environment_variable {
      name  = "ARTEFACTS_BUCKET"
      value = local.artefacts_bucket
    }

    environment_variable {
      name  = "GITHUB_REPO"
      value = var.code_build["infra_repo"]
    }

    environment_variable {
      name  = "GITHUB_ORG"
      value = var.code_build["github_org"]
    }

    environment_variable {
      name  = "PACKAGE_NAME"
      value = "alfresco-terraform.tar"
    }
  }
  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["infra_repo"]}"
    buildspec = templatefile("./templates/release_buildspec.yml.tpl", {})

    auth {
      type     = "OAUTH"
      resource = data.aws_ssm_parameter.jenkins_token.value
    }
  }
}

