resource "aws_codepipeline" "oracle_backups_codepipeline" {

  for_each = { for job in var.oracle_backup_jobs: "${job.type}-${job.environment}-${job.host}" => job }

    name     = "oracle-backup-pipeline-${each.key}"
    role_arn = local.service_role

    artifact_store {
      location = local.artifact_store.location
      type     = local.artifact_store.type
    }

    stage {

      name = local.sourcecode_action_name
        
        action {
          name             = local.code_stage.action.name
          category         = local.code_stage.action.category
          owner            = local.code_stage.action.owner
          provider         = local.code_stage.action.provider
          version          = local.code_stage.action.version
          output_artifacts = local.code_stage.action.output_artifacts
          namespace        = local.code_stage.action.namespace
          configuration = {
            Owner                = local.code_stage.action.configuration.Owner
            Repo                 = local.code_stage.action.configuration.Repo
            Branch               = local.code_stage.action.configuration.Branch
            PollForSourceChanges = local.code_stage.action.configuration.PollForSourceChanges
            // OAuthToken           = local.code_stage.action.configuration.OAuthToken
          }
        }
    }

    stage {

      name = "Oracle-Backup"

      action {
        name             = "oracle-backup-${each.key}"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = local.code_stage.action.output_artifacts
        version          = "1"
        configuration = {
          ProjectName = "oracle-backup-${each.key}"
          EnvironmentVariables = jsonencode([
            for e in local.build_environment_spec.environment_variables:
            {
              name  = e.key
              value = e.value
              type  = "PLAINTEXT"
            } 
            ])
          }
          run_order  = 1
        } 
    }

    stage {

      name = "Oracle-Validate"

      action {
        name             = "oracle-validate-chunks-${each.value.environment}-${each.value.host}"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = local.code_stage.action.output_artifacts
        version          = "1"
        configuration = {
          ProjectName = "oracle-validate-chunks-${each.value.environment}-${each.value.host}"
          EnvironmentVariables = jsonencode([
            for e in local.build_environment_spec.environment_variables:
            {
              name  = e.key
              value = e.value
              type  = "PLAINTEXT"
            } 
            ])
          }
          run_order  = 1
        } 
    }

}
