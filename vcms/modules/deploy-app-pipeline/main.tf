resource "aws_codepipeline" "pipeline" {
  name     = "vcms-${var.environment_type}-deploy-app"
  role_arn = var.iam_role_arn
  tags     = var.tags

  artifact_store {
    type     = "S3"
    location = var.pipeline_bucket
  }

  stage {
    name = "Source"
    action {
      name             = "code"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]
      configuration = {
        Owner                = var.repo_owner
        Repo                 = var.repo_name
        Branch               = var.repo_branch
        PollForSourceChanges = false
      }
    }
  }


  stage {
    name = "Deploy-App"
    action {
      name             = "Deploy-App"
      input_artifacts  = ["code"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "${var.prefix}-deploy-app"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_TYPE",
              "value" : var.environment_type,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACCOUNT_ID",
              "value" : var.account_id,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "APP_VERSION",
              "value" : "current_eb_version",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }


  dynamic "stage" {
  for_each = var.load_test_stages
  content {
    name = stage.value.name
    action {
      name             = stage.value.name
      input_artifacts  = ["code"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "${var.prefix}-trigger-build"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : var.environment_type,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PROJECT_NAME",
              "value" : "vcms-${var.environment_type}-${stage.value.name}-build",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
 }

  stage {
    name = "DB-Migration"
    action {
      name             = "DB-Migration"
      input_artifacts  = ["code"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "${var.prefix}-trigger-build"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : var.environment_type,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ENV_VAR_OVERIDES",
              "value" : "name=ACTION,value=migrate,type=PLAINTEXT",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PROJECT_NAME",
              "value" : "vcms-${var.environment_type}-db-migration-build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "APP_VERSION",
              "value" : "current_eb_version",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }


  dynamic "stage" {
  for_each = var.test_stages
  content {
    name = stage.value.name
    action {
      name             = stage.value.name
      input_artifacts  = ["code"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "${var.prefix}-trigger-build"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : var.environment_type,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PROJECT_NAME",
              "value" : "vcms-${var.environment_type}-${stage.value.name}-build",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
 }
}
