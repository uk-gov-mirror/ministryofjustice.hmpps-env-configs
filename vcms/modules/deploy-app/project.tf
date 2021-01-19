###deploy app
resource "aws_codebuild_project" "deploy-app" {
  name           = "${var.prefix}-deploy-app"
  description    = var.prefix
  build_timeout  = "15"
  queued_timeout = "30"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-deploy-app"
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
    image                       = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/terraform-builder-0-12:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true
  }
  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["app_repo"]}"
    buildspec = templatefile("./templates/deploy_app_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}



###Trigger Build Project
resource "aws_codebuild_project" "trigger-build" {
  name           = "${var.prefix}-trigger-build"
  description    = var.prefix
  build_timeout  = "15"
  queued_timeout = "30"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-trigger-build"
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
    image                       = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/terraform-builder-0-12:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true

    environment_variable {
      name  = "ENV_TYPE"
      value = "vcms_env_type"
    }

    environment_variable {
      name  = "ENV_VAR_OVERIDES"
      value = "environment_variables_override"
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = "project_name"
    }
  }


  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["app_repo"]}"
    buildspec = templatefile("./templates/trigger_build_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}
