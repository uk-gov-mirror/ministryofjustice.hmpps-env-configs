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
  }

  stage {
    name = "CreatePackage"
    action {
      name            = "createPackage"
      input_artifacts = concat(keys(var.github_repositories))
      output_artifacts = ["package"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.package_project_name
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              name  = "ENVIRONMENT_NAME"
              type  = "PLAINTEXT"
              value = var.environment_name
            },
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
          input_artifacts = ["package"]
          configuration = {
            ProjectName   = length(action.value) > 2 ? action.value[2] : var.tf_plan_project_name
            PrimarySource = "package"
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
                  value = action.value[0]
                },
                {
                  "name" : "TASK",
                  "value" : length(action.value) > 2 ? "${action.value[1]}" :"terraform_plan",
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

      #Apply
      dynamic "action" {
        for_each = stage.value.actions
        content {
          name            = "${action.key}Apply"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 3
          input_artifacts = ["package"]
          configuration = {
            ProjectName   = length(action.value) > 2 ? action.value[2] : var.tf_apply_project_name
            PrimarySource = "package"
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
                  value = action.value[0]
                },
                {
                  "name" : "TASK",
                  "value" : length(action.value) > 2 ? "${action.value[1]}" : local.apply_task,
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
    }
  }
}
