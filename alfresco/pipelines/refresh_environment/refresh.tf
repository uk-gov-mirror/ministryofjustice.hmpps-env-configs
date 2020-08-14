resource "aws_codepipeline" "refresh" {
  for_each = toset(local.refresh_environments)
  name     = format("${local.prefix}-%s", each.key)
  role_arn = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags     = var.tags

  artifact_store {
    type     = "S3"
    location = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
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
        Owner                = "ministryofjustice"
        Repo                 = "hmpps-delius-alfresco-shared-terraform"
        Branch               = "develop"
        PollForSourceChanges = false
      }
    }
    action {
      name             = "versions"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["versions"]
      configuration = {
        Owner                = "ministryofjustice"
        Repo                 = "hmpps-alfresco-infra-versions"
        Branch               = "develop"
        PollForSourceChanges = false
      }
    }
  }
  stage {
    name = format("%s-summary", each.key)
    action {
      name            = "show-database-target"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["ansible"]
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
              "value" : "database_snapshot",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "CREATE_SNAPSHOT",
              "value" : false,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = format("approve-%s-refresh", each.key)
    action {
      name      = "Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1
      configuration = {
        CustomData = "Please review and approve change to proceed? Note this is a destructive task"
      }
    }
  }
  stage {
    name = format("stage-1-%s-prepare", each.key)
    action {
      name            = "build-refresh-components"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "content_refresh",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "stop-alfresco"
      input_artifacts = ["versions"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["terraform"]
        PrimarySource = "versions"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "asg",
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
      name            = "stop-solr"
      input_artifacts = ["versions"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["terraform"]
        PrimarySource = "versions"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "solr",
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
      name            = "create-snapshot"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["ansible"]
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
              "value" : "database_snapshot",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "CREATE_SNAPSHOT",
              "value" : true,
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = format("stage-2-%s-refresh-tasks", each.key)
    action {
      name            = "content-sync"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["ansible"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "content_refresh",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "restore-database"
      input_artifacts = ["versions"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["terraform"]
        PrimarySource = "versions"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "database",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "solr-snapshot"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["ansible"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "ansible/ebs/snapshot",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
  stage {
    name = format("approve-%s-services-start", each.key)
    action {
      name      = "Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1
      configuration = {
        CustomData = "Please check content-sync task is complete, refer to CloudWatch esadmin log group. Proceed?"
      }
    }
  }
  stage {
    name = format("stage-3-%s-final", each.key)
    action {
      name            = "set-solr-ebs-snapshot-id"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["ansible"]
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
              "value" : "ansible/ebs/param_store",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "ansible",
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
      name            = "destroy-refresh-components"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = local.projects["terraform"]
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "destroy",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "content_refresh",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "start-alfresco"
      input_artifacts = ["versions"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = local.projects["terraform"]
        PrimarySource = "versions"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "asg",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
    action {
      name            = "start-solr"
      input_artifacts = ["versions"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      configuration = {
        ProjectName   = local.projects["terraform"]
        PrimarySource = "versions"
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "ENVIRONMENT_NAME",
              "value" : each.key,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "build",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "ARTEFACTS_BUCKET",
              "value" : local.artefacts_bucket,
              "type" : "PLAINTEXT"
            },
            {
              "name" : "PACKAGE_NAME",
              "value" : "alfresco-terraform.tar",
              "type" : "PLAINTEXT"
            },
            {
              "name" : "COMPONENT",
              "value" : "solr",
              "type" : "PLAINTEXT"
            }
          ]
        )
      }
    }
  }
}
