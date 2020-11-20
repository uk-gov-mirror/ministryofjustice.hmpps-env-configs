resource "aws_codepipeline" "pipeline" {
  name     = local.name
  role_arn = var.iam_role_arn
  tags     = merge(var.tags, { Name = local.name })

  artifact_store {
    type     = "S3"
    location = var.artefacts_bucket
  }

  stage {
    name = "Source"
    dynamic "action" {
      for_each = var.github_repositories
      content {
        name             = action.key
        category         = "Source"
        owner            = "ThirdParty"
        provider         = "GitHub"
        version          = "1"
        output_artifacts = [action.key]
        configuration = {
          Owner                = var.repo_owner
          Repo                 = action.value[0]
          Branch               = length(action.value) > 1 ? action.value[1] : "develop"
          PollForSourceChanges = false
        }
      }
    }
    action {
      name             = "utils"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["utils"]
      configuration = {
        Owner                = var.repo_owner
        Repo                 = "hmpps-engineering-pipelines-utils"
        Branch               = "develop"
        PollForSourceChanges = false
      }
    }
  }

  dynamic "stage" {
    for_each = var.sec_access_stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions
        content {
          name            = "${action.key}Apply"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 1
          input_artifacts = concat(["utils"], keys(var.github_repositories))
          configuration = {
            ProjectName   = aws_codebuild_project.project.id
            PrimarySource = "code"
            EnvironmentVariables = jsonencode(
              [
                {
                  name  = "ENVIRONMENT_NAME"
                  type  = "PLAINTEXT"
                  value = "sec-access"
                },
                {
                  name  = "COMPONENT"
                  type  = "PLAINTEXT"
                  value = action.value
                },
                {
                  "name" : "ACTION_TYPE",
                  "value" : "apply",
                  "type" : "PLAINTEXT"
                },
                {
                  "name" : "TASK",
                  "value" : "terraform_plan",
                  "type" : "PLAINTEXT"
                }
              ]
            )
          }
        }
      }
    }
  }
  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions
        content {
          name            = "${action.key}Apply"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 1
          input_artifacts = concat(["utils"], keys(var.github_repositories))
          configuration = {
            ProjectName   = aws_codebuild_project.project.id
            PrimarySource = "code"
            EnvironmentVariables = jsonencode(
              [
                {
                  name  = "ENVIRONMENT_NAME"
                  type  = "PLAINTEXT"
                  value = var.environment_name
                },
                {
                  name  = "COMPONENT"
                  type  = "PLAINTEXT"
                  value = action.value
                },
                {
                  "name" : "ACTION_TYPE",
                  "value" : "apply",
                  "type" : "PLAINTEXT"
                },
                {
                  "name" : "TASK",
                  "value" : "terraform_plan",
                  "type" : "PLAINTEXT"
                }
              ]
            )
          }
        }
      }
    }
  }
}
