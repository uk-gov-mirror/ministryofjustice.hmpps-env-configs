resource "aws_codepipeline" "pipeline" {
  name     = local.pipeline_name
  role_arn = local.iam_role_arn
  tags     = merge(local.tags, { Name = local.pipeline_name })

  artifact_store {
    type     = "S3"
    location = local.artefacts_bucket
  }

  stage {
    name = "Source"
    dynamic "action" {
      for_each = local.github_repositories
      content {
        name             = action.key
        category         = "Source"
        owner            = "ThirdParty"
        provider         = "GitHub"
        version          = "1"
        output_artifacts = [action.key]
        configuration = {
          Owner                = local.repo_owner
          Repo                 = action.value[0]
          Branch               = length(action.value) > 1 ? action.value[1] : "develop"
          PollForSourceChanges = false
        }
      }
    }
  }

  dynamic "stage" {
    for_each = local.stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions
        content {
          name            = "${action.key}Build"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          run_order       = 1
          input_artifacts = [action.value]
          configuration = {
            ProjectName   = aws_codebuild_project.project.id
            PrimarySource = action.value
            EnvironmentVariables = jsonencode(
              concat(local.environment_variables)
            )
          }
        }
      }
    }
  }
}
