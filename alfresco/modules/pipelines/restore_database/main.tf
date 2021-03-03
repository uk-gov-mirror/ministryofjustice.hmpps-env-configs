resource "aws_codepipeline" "pipeline" {
  for_each = toset(var.environments)
  name     = format("${var.prefix}-%s", each.key)
  role_arn = var.iam_role_arn
  tags     = var.tags

  artifact_store {
    type     = "S3"
    location = var.pipeline_buckets["pipeline_bucket"]
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
    action {
      name             = "utils"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["utils"]
      configuration = {
        Owner                = "ministryofjustice"
        Repo                 = "hmpps-engineering-pipelines-utils"
        Branch               = "develop"
        PollForSourceChanges = false
      }
    }
  }
  stage {
    name = "BuildPackages"
    action {
      name             = "TerraformPackage"
      input_artifacts  = ["code", "utils"]
      output_artifacts = ["package"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = var.projects["version"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          concat(
            [
              {
                "name" : "ENVIRONMENT_NAME",
                "value" : each.key,
                "type" : "PLAINTEXT"
              },
              {
                "name" : "RELEASE_PKGS_PATH",
                "value" : "projects",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "DEV_PIPELINE_NAME",
                "value" : "codepipeline/alf-infra-build-alfresco-dev",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "TASK",
                "value" : "get_package",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
  }
  stage {
    name = format("%s-services-stop", each.key)
    action {
      name             = "alfresco_plan"
      input_artifacts  = ["package"]
      output_artifacts = ["alfresco_plan"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = var.projects["plan"]
        PrimarySource = "package"
        EnvironmentVariables = jsonencode(
          concat(
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
                "name" : "TASK",
                "value" : "terraform_plan",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "TF_VAR_restoring",
                "value" : "enabled",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
    action {
      name             = "solr_plan"
      input_artifacts  = ["package"]
      output_artifacts = ["solr_plan"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName   = var.projects["plan"]
        PrimarySource = "package"
        EnvironmentVariables = jsonencode(
          concat(
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
                "name" : "TASK",
                "value" : "terraform_plan",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "TF_VAR_restoring",
                "value" : "enabled",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
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
      input_artifacts = ["alfresco_plan"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["apply"]
        PrimarySource = "alfresco_plan"
        EnvironmentVariables = jsonencode(
          concat(
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
                "name" : "TASK",
                "value" : "terraform_apply",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "TF_VAR_restoring",
                "value" : "enabled",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
    action {
      name            = "solr_apply"
      input_artifacts = ["solr_plan"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["apply"]
        PrimarySource = "solr_plan"
        EnvironmentVariables = jsonencode(
          concat(
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
                "name" : "TASK",
                "value" : "terraform_apply",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "TF_VAR_restoring",
                "value" : "enabled",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
  }
  stage {
    name = format("%s-database-destroy", each.key)
    action {
      name            = "database_destroy"
      input_artifacts = ["package"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["ansible"]
        PrimarySource = "package"
        EnvironmentVariables = jsonencode(
          concat(
            [
              {
                "name" : "ENVIRONMENT_NAME",
                "value" : each.key,
                "type" : "PLAINTEXT"
              },
              {
                "name" : "COMPONENT",
                "value" : "ansible/rds/delete_instance",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "TASK",
                "value" : "ansible",
                "type" : "PLAINTEXT"
              },
              {
                "name" : "DELETE_DB_INSTANCE",
                "value" : "yes",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
  }
  stage {
    name = format("%s-database-restore", each.key)
    action {
      name            = "database_apply"
      input_artifacts = ["package"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["apply"]
        PrimarySource = "package"
        EnvironmentVariables = jsonencode(
          concat(
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
                "name" : "TASK",
                "value" : "apply",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
  }
  stage {
    name = format("%s-services-start", each.key)
    action {
      name            = "alfresco_apply"
      input_artifacts = ["package"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["apply"]
        PrimarySource = "package"
        EnvironmentVariables = jsonencode(
          concat(
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
                "name" : "TASK",
                "value" : "apply",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
    action {
      name            = "solr_apply"
      input_artifacts = ["package"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["apply"]
        PrimarySource = "package"
        EnvironmentVariables = jsonencode(
          concat(
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
                "name" : "TASK",
                "value" : "apply",
                "type" : "PLAINTEXT"
              }
            ],
            local.environment_vars
          )
        )
      }
    }
  }
}
