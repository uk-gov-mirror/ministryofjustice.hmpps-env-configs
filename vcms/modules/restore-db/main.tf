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

#Create restoredb
  stage {
    name = format("%s-create-db-from-snapshot", each.key)
    action {
      name            = "create-db-from-snapshot-plan"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = var.projects["restoredb"]
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
              value = "database"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "db_terraform_plan",
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
    action {
      name      = "Approve"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2
      configuration = {
        CustomData = "Please review and approve change to proceed?"
      }
    }

    action {
      name            = "create-db-from-snapshot-apply"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      configuration = {
        ProjectName   = var.projects["restoredb"]
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
            value = "database"
          },
          {
            "name" : "ACTION_TYPE",
            "value" : "db_terraform_apply",
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

  #Cleanup
    stage {
      name = format("%s-cleanup-db-state", each.key)
      action {
        name      = "approve-db-terraform-import"
        category  = "Approval"
        owner     = "AWS"
        provider  = "Manual"
        version   = "1"
        run_order = 1
        configuration = {
          CustomData = "Approve import of new RDS DB"
        }
      }

      action {
        name            = "db-terraform-import"
        input_artifacts = ["code"]
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        run_order       = 2
        configuration = {
          ProjectName   = var.projects["restoredb"]
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
              value = "database"
            },
            {
              "name" : "ACTION_TYPE",
              "value" : "db_terraform_import",
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

  #Apply DB
    stage {
      name = format("%s-db-apply", each.key)
      action {
        name            = "db-plan"
        input_artifacts = ["code"]
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        run_order       = 1
        configuration = {
          ProjectName   = var.projects["restoredb"]
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
                value = "database"
              },
              {
                "name" : "ACTION_TYPE",
                "value" : "terraform_plan",
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
      action {
        name      = "Approve"
        category  = "Approval"
        owner     = "AWS"
        provider  = "Manual"
        version   = "1"
        run_order = 2
        configuration = {
          CustomData = "Please review and approve change to proceed?"
        }
      }

      action {
        name            = "db-apply"
        input_artifacts = ["code"]
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        run_order       = 3
        configuration = {
          ProjectName   = var.projects["restoredb"]
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
              value = "database"
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
