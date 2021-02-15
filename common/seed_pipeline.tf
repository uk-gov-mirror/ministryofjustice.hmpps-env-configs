resource "aws_codepipeline" "pipeline" {
  name     = "create-pipelines-eng-dev"
  role_arn = aws_iam_role.codebuild.arn
  tags     = local.tags

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline.bucket
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
        Owner                = "ministryofjustice"
        Repo                 = "hmpps-engineering-pipelines"
        Branch               = "develop"
        PollForSourceChanges = false
      }
    }
  }
  stage {
    name = "PipelineComponents"
    action {
      name            = "Common"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "common",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "Ansible"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.ansible3.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "codepipelines",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "ansible",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "Engineering"
    action {
      name            = "lambda_functions"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "lambda_functions",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
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
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "eng-dev-webhook-events",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PRE_BUILD_TARGET",
              "value" : "functions",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PRE_BUILD_ACTION",
              "value" : "lambda_packages",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : aws_s3_bucket.artefacts.bucket,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "pipeline-approvals"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "operations/pipeline_approvals",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PRE_BUILD_TARGET",
              "value" : "functions",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PRE_BUILD_ACTION",
              "value" : "lambda_packages",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : aws_s3_bucket.artefacts.bucket,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "Security"
    action {
      name            = "CreateCredentials"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "security/credentials",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "ManageHostedZones"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "security/hosted-zone-pipeline",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "AlfDevSecurityAccess"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "security/access",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "Alfresco"
    action {
      name            = "AlfBase"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "alfresco/base",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "AlfPackerBuilds"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "alfresco/pipelines/packer",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "AlfRefreshEnvironments"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "alfresco/pipelines/refresh_environment",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "AlfInfrastructure"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "alfresco/pipelines/infrastructure",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "AlfBackupTasks"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "alfresco/pipelines/backups",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "AlfDatabaseTasks"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "alfresco/pipelines/database_tasks",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "MIS"
    action {
      name            = "MisBase"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "mis/base",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "MisSnapshot"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "mis/pipelines/snapshot",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "MisInfrastructure"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "mis/pipelines/infrastructure",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "MisNextcloudDbBackups"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "mis/pipelines/nextcloud-db-bkups",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "VCMS"
    action {
      name            = "VCMSBase"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "vcms/base",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "VcmsTerraform"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "vcms/pipelines/build-infra",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "VcmsApplication"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "vcms/pipelines/build-app",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "Ten10"
    action {
      name            = "ten10"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "ten10",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = "Webhook-Management"
    action {
      name            = "webhooks"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.pipelines.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "COMPONENT",
              "value" : "webhooks",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : "terraform",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
}
