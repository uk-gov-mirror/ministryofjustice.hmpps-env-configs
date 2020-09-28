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
    name = format("approve-%s-bkup-ebs", each.key)
    action {
      name      = "Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1
      configuration = {
        CustomData = "Please review and approve change to proceed? Note this task will stop instances"
      }
    }
  }

  stage {
    name = format("%s-bkup-ebs", each.key)
    action {
      name            = "bps"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["snapshot"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "bps",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "backup",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "bcs"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["snapshot"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "bcs",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "backup",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "bfs"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["snapshot"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "bfs",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "backup",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "bws"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["snapshot"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "bws",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "backup",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "dis"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["snapshot"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENV_TYPE",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "dis",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "backup",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
}
