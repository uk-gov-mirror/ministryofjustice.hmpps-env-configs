resource "aws_codebuild_project" "oracle_backups_codebuild_project" {
  
  for_each = { for job in var.oracle_backup_jobs: "${job.type}-${job.environment}-${job.host}" => job }

    name           = "oracle-backup-${each.key}"
    description    = "Oracle ${each.value.type} backup for ${each.value.host} on ${each.value.environment}"
    build_timeout  = local.build_timeout
    queued_timeout = local.queued_timeout

    service_role   = local.service_role
    tags = merge(
      local.tags,
      {
        "Name" = "oracle-backup-${each.key}"
      },
    )
  
    artifacts {
      type           = local.build_artifacts.type
    }

    source {
      type            = local.build_source.type
      location        = local.build_source.location
      git_clone_depth = local.build_source.git_clone_depth
      buildspec       = local.build_source.buildspec
    }

    source_version = "ALS-1377"

    environment {
      compute_type                = local.build_environment_spec.compute_type
      image                       = var.code_build.ansible_image
      type                        = local.build_environment_spec.type
      image_pull_credentials_type = local.build_environment_spec.image_pull_credentials_type
      privileged_mode             = true

        environment_variable {
          name  = "ENVIRONMENT"
          value = each.value.environment
          type  = "PLAINTEXT"
        } 

        environment_variable {
          name  = "HOST"
          value = each.value.host
          type  = "PLAINTEXT"
        } 

        environment_variable {
          name  = "ACTION"
          value = "rman-backup"
          type  = "PLAINTEXT"
        } 
        
        environment_variable {
          name  = "DAILY_WEEKLY"
          value = each.value.type
          type  = "PLAINTEXT"
        } 

        environment_variable {
          name  = "FIX_ABSENT_CHUNKS"
          value = "false"
          type  = "PLAINTEXT"
        } 

        environment_variable {
          name  = "OEM_ENV"
          value = each.value.environment != "delius-prod" && each.value.environment != "delius-pre-prod" && each.value.environment != "delius-stage" && each.value.environment != "delius-perf" ? "dev" : "prod"
          type  = "PLAINTEXT"
        } 
      }

    logs_config {
      cloudwatch_logs {
        group_name  = local.group_name
        stream_name = "oracle-backup-${each.key}"
      }
    }

    vpc_config {
      vpc_id             = local.vpc_config.vpc_id
      subnets            = local.vpc_config.subnet_ids
      security_group_ids = local.vpc_config.security_group_ids
    }

}
