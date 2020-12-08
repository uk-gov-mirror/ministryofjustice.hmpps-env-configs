resource "aws_codepipeline" "pipeline" {
  for_each = toset(var.environments)
  name     = format("%s-${var.prefix}-${var.task}", each.key)
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
    name = format("%s-${var.prefix}-${var.task}", each.key)
    action {
      name            = "${var.prefix}-${var.task}"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["nextclouddb"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "db-backup",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TASK",
              "value" : var.task,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
}
