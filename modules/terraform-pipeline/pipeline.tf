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

  stage {
    name = "CreatePackage"
    action {
      name            = "BuildTfPAckage"
      input_artifacts = concat(["utils"], keys(var.github_repositories))
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.project_name
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "TASK",
              "value" : "build_tfpackage",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "BUILDS_CACHE_BUCKET",
              "value" : var.cache_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  
  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = var.approval_required ? stage.value.actions : {}
        content {
          name            = "${action.key}Plan"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 1
          input_artifacts = concat(["utils"], keys(var.github_repositories))
          configuration = {
            ProjectName   = var.project_name
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
                  "name" : "TASK",
                  "value" : "terraform_plan",
                  "type" : "PLAINTEXT"
                },
                {
                  "name" : "BUILDS_CACHE_BUCKET",
                  "value" : var.cache_bucket,
                  "type" : "PLAINTEXT"
                }
              ]
            )
          }
        }
      }
      # Approve
      dynamic "action" {
        for_each = var.approval_required ? ["1"] : []
        content {
          name      = "ApproveChanges"
          category  = "Approval"
          owner     = "AWS"
          provider  = "Manual"
          version   = "1"
          run_order = 2
          configuration = var.pipeline_approval_config
        }
      }

      # Apply
      dynamic "action" {
        for_each = stage.value.actions
        content {
          name            = "${action.key}Apply"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 3
          input_artifacts = concat(["utils"], keys(var.github_repositories))
          configuration = {
            ProjectName   = var.project_name
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
                  "name" : "TASK",
                  "value" : var.approval_required ? "terraform_apply" : "apply",
                  "type" : "PLAINTEXT"
                },
                {
                  "name" : "BUILDS_CACHE_BUCKET",
                  "value" : var.cache_bucket,
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
