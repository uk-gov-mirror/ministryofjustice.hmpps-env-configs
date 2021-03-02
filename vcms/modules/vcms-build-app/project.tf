###Tag repo
resource "aws_codebuild_project" "tagrepo" {
  name           = "${var.prefix}-tagrepo"
  description    = "VCMS Tag repo project"
  build_timeout  = "60"
  queued_timeout = "60"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-tagrepo"
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
    buildspec = templatefile("./templates/release_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}



###Create docker images
resource "aws_codebuild_project" "package" {
  name           = "${var.prefix}-package"
  description    = "VCMS Package docker artefacts"
  build_timeout  = "60"
  queued_timeout = "60"
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
  }
  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["app_repo"]}"
    buildspec = templatefile("./templates/package_application_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}



##Unit tests
resource "aws_codebuild_project" "unit-test" {
  name           = "${var.prefix}-unit-test"
  description    = "VCMS Unit Test"
  build_timeout  = "60"
  queued_timeout = "60"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-unit-test"
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
  }
  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["app_repo"]}"
    buildspec = templatefile("./templates/unit_test_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}


##Snyk
resource "aws_codebuild_project" "snyk" {
  name           = "${var.prefix}-snyk"
  description    = "VCMS Snyk codebase scan"
  build_timeout  = "60"
  queued_timeout = "60"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-snyk"
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
    image                       = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/base-snyk"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true
  }
  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["app_repo"]}"
    buildspec = templatefile("./templates/synk_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}


###Trigger Codepipeline
resource "aws_codebuild_project" "code-pipeline" {
  name           = "${var.prefix}-trigger-code-pipeline"
  description    = "VCMS trigger Codepipeline"
  build_timeout  = "60"
  queued_timeout = "60"
  service_role   = var.code_build["iam_role_arn"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-trigger-code-pipeline"
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
    buildspec = templatefile("./templates/trigger_code_pipeline_buildspec.yml.tpl", {})
    auth {
      type     = "OAUTH"
      resource = var.code_build["jenkins_token_ssm"]
    }
  }
}
