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

  dynamic "stage" {
    for_each = var.pre_stages
    content {
      name = stage.value.name
      dynamic "action" {
        for_each = stage.value.actions
        content {
          name            = action.key
          input_artifacts = concat(keys(var.github_repositories))
          output_artifacts = var.input_artifact
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 1
          configuration = {
            ProjectName   = var.package_project_name
            PrimarySource = "code"
            EnvironmentVariables = jsonencode(
              concat(
                [
                  {
                    "name" : "TASK",
                    "value" : action.value[0],
                    "type" : "PLAINTEXT"
                  }],
                  local.environment_variables
              )
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
        for_each = var.approval_required ? stage.value.actions : {}
        content {
          name            = "${action.key}Plan"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 1
          input_artifacts = var.input_artifact
          output_artifacts = ["${action.key}_plan"]
          configuration = {
            ProjectName   = length(action.value) > 2 ? action.value[2] : var.tf_plan_project_name
            PrimarySource = "package"
            EnvironmentVariables = jsonencode(
              concat(
                [
                  {
                    name  = "COMPONENT"
                    type  = "PLAINTEXT"
                    value = action.value[0]
                  },
                  {
                    "name" : "TASK",
                    "value" : length(action.value) > 2 ? "${action.value[1]}-plan" :"terraform_plan",
                    "type" : "PLAINTEXT"
                  }
                ],
                local.environment_variables
              )
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
          input_artifacts = var.approval_required ? ["${action.key}_plan"]: var.input_artifact
          configuration = {
            ProjectName   = length(action.value) > 2 ? action.value[2] : var.tf_apply_project_name
            PrimarySource = "${action.key}_plan"
            EnvironmentVariables = jsonencode(
              concat(
                [
                  {
                    name  = "COMPONENT"
                    type  = "PLAINTEXT"
                    value = action.value[0]
                  },
                  {
                    "name" : "TASK",
                    "value" : length(action.value) > 2 ? "${action.value[1]}" : local.apply_task,
                    "type" : "PLAINTEXT"
                  }
                ],
                local.environment_variables
              )
            )
          }
        }
      }
    }
  }

  # Trigger Smoke Test
  dynamic "stage" {
  for_each = var.test_stages
  content {
    name = stage.value.name
    action {
      name             = stage.value.name
      input_artifacts = var.input_artifact
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = "delius-trigger-build"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_NAME",
              "value" : var.environment_name,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PROJECT_NAME",
              "value" : var.smoke_test_pipeline_name,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
 }
}
