resource "aws_codepipeline" "pipeline" {
  for_each = toset(var.environments)
  name     = format("${var.prefix}-%s", each.key)
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
    name = format("%s-backup-tasks", each.key)
    action {
      name            = "generate-configs"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "alfresco-prepare"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "SSM_TASKS_PREFIX",
              "value" : "/codebuild/alfresco/tasks",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "content-backup"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = "alfresco-task-handler"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "GITHUB_REPO",
              "value" : "hmpps-delius-alfresco-shared-terraform",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "SSM_TASKS_PREFIX",
              "value" : "/codebuild/alfresco/tasks",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK_NAME",
              "value" : "content",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPOSE_FILE_NAME",
              "value" : "docker-compose-alfresco-backup.yml",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "DAYS_TO_DELETE",
              "value" : "180",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "database-backup"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = "alfresco-task-handler"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "GITHUB_REPO",
              "value" : "hmpps-delius-alfresco-shared-terraform",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "SSM_TASKS_PREFIX",
              "value" : "/codebuild/alfresco/tasks",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK_NAME",
              "value" : "psql",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPOSE_FILE_NAME",
              "value" : "docker-compose-alfresco-backup.yml",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "DAYS_TO_DELETE",
              "value" : "180",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "elasticsearch-backup"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = "hmpps-eng-builds-ansible3"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "ansible/lambda/trigger_elasticsearch_function",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK_NAME",
              "value" : "submit-create-snapshot",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }

}
