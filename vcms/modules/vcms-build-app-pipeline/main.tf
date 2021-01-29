resource "aws_codepipeline" "pipeline" {
  name     = "vcms-build-app"
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
    name = "vcms-snyk"
    action {
      name             = "vcms-snyk"
      input_artifacts  = ["code"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "vcms-build-app-snyk"
        PrimarySource = "code"
      }
    }
  }


  stage {
    name = "vcms-unit-test"
    action {
      name             = "vcms-unit-test"
      input_artifacts  = ["code"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "vcms-build-app-unit-test"
        PrimarySource = "code"
      }
    }
  }

  stage {
    name = "vcms-tag-repo"
    action {
      name             = "vcms-tag-repo"
      input_artifacts  = ["code"]
      output_artifacts = ["tagcode"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "vcms-build-app-tagrepo"
        PrimarySource = "code"
      }
    }
  }

  stage {
    name = "vcms-package"
    action {
      name             = "vcms-package-app"
      input_artifacts  = ["tagcode"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "vcms-build-app-package"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "DOCKER_IMAGE_TYPE",
              "value" : "vcms",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "DOCKER_FILE",
              "value" : ".docker/app.dockerfile",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "BUILD_ARGS",
              "value" : "--build-arg RUN_COMPOSER=true --build-arg BUILD_TAG_ARG=$BUILD_TAG",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACCOUNT_ID",
              "value" : var.account_id,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }

    action {
      name             = "vcms-package-artisan"
      input_artifacts  = ["tagcode"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "vcms-build-app-package"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "DOCKER_IMAGE_TYPE",
              "value" : "artisan",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "DOCKER_FILE",
              "value" : ".docker/artisan.dockerfile",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACCOUNT_ID",
              "value" : var.account_id,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }

  stage {
    name = "Promotion-to-Dev"
    action {
      name             = "Promotion"
      input_artifacts  = ["tagcode"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "vcms-build-app-trigger-code-pipeline"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "PIPELINE_NAME",
              "value" : "vcms-dev-deploy-app",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
}
