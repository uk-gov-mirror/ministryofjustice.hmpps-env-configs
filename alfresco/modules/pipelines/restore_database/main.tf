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
    name = format("%s-services-stop", each.key)
    action {
      name            = "alfresco_plan"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "asg",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "plan",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TF_VAR_restoring",
              "value" : "enabled",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "solr_plan"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "solr",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "plan",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TF_VAR_restoring",
              "value" : "enabled",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name      = "approve-apply"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2
      configuration = {
        CustomData = "Please review plans and approve to proceed?"
      }
    }
    action {
      name            = "alfresco_apply"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "asg",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TF_VAR_restoring",
              "value" : "enabled",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "solr_apply"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "solr",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "TF_VAR_restoring",
              "value" : "enabled",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = format("%s-database-restore", each.key)
    action {
      name            = "database_plan"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "database",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "plan",
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
      name      = "approve-apply"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2
      configuration = {
        CustomData = "Please review plans and approve to proceed?"
      }
    }
    action {
      name            = "database_apply"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "database",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
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
  }
  stage {
    name = format("%s-services-start", each.key)
    action {
      name            = "alfresco_plan"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "asg",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "plan",
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
      name            = "solr_plan"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "solr",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "plan",
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
      name      = "approve-apply"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2
      configuration = {
        CustomData = "Please review plans and approve to proceed?"
      }
    }
    action {
      name            = "alfresco_apply"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "asg",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
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
      name            = "solr_apply"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "solr",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : var.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
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
  }
}
