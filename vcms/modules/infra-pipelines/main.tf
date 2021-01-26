resource "aws_codepipeline" "pipeline" {
for_each = toset(var.environments)
  name     = format("${var.prefix}-%s", each.key)
  role_arn = var.iam_role_arn
  tags     = var.tags
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
          Branch               = length(action.value) > 1 ? action.value[1] : "main"
          PollForSourceChanges = false
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
          input_artifacts = concat(keys(var.github_repositories))
          configuration = {
            ProjectName   = var.projects["buildinfra"]
            PrimarySource = "code"
            EnvironmentVariables = jsonencode(
              [
                {
                  name  = "ARTEFACTS_BUCKET"
                  type  = "PLAINTEXT"
                  value = var.artefacts_bucket
                },
                {
                  name  = "ENVIRONMENT_NAME"
                  type  = "PLAINTEXT"
                  value = each.key
                },
                {
                  name  = "COMPONENT"
                  type  = "PLAINTEXT"
                  value = action.value
                },
                {
                  "name" : "ACTION_TYPE",
                  "value" : "terraform_apply",
                  "type" : "PLAINTEXT"
                },
                {
                  "name" : "PACKAGE_NAME",
                  "value" : "vcms-terraform.tar",
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
        ProjectName   = "vcms-trigger-build"
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PROJECT_NAME",
              "value" : "vcms-${each.key}-${stage.value.name}-build",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
 }
}
