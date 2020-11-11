resource "aws_codepipeline" "pipeline" {
  name     = "${var.prefix}-functions-builder"
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
        PollForSourceChanges = true
      }
    }
  }
  stage {
    name = "Docker"
    action {
      name            = "python-builder"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "python-builder",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "BUILD_IMAGE",
              "value" : "mojdigitalstudio/hmpps-lambda-python-builder",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "content-refresh"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "content-refresh",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "BUILD_IMAGE",
              "value" : "mojdigitalstudio/redis-s3-sync",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "Boto3"
    action {
      name            = "boto3"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "boto3",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "webhook-handler"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "webhook-handler",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "webhook-dispatcher"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "webhook-dispatcher",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "webhook-events"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "webhook-events",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "s3RestoreSubmit"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "s3RestoreSubmit",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "BASE_PKG",
              "value" : "boto3",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "s3RestoreWorker"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "s3RestoreWorker",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "Support"
    action {
      name            = "content-refresh"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "content-refresh",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "alert_handler"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "alert_handler",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "aws_elasticsearch"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-docker-tasks"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "aws-elasticsearch",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "package",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
}
