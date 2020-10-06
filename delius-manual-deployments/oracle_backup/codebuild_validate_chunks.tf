resource "aws_codebuild_project" "oracle_validate_chunks_codebuild_project" {
  
  for_each = { for job in var.oracle_validate_chunks_jobs: "${job.environment}-${job.host}" => job }

    name           = "oracle-validate-chunks-${each.key}"
    description    = "Validate chunks for ${each.value.host} on ${each.value.environment}"
    build_timeout  = local.build_timeout
    queued_timeout = local.queued_timeout

    service_role   = local.service_role
    tags = merge(
      local.tags,
      {
        "Name" = "oracle-validate-chunks-${each.key}"
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

    source_version = "master"

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
          value = "validate_chunks"
          type  = "PLAINTEXT"
        } 
        
        environment_variable {
          name  = "DAILY_WEEKLY"
          value = "Not-Required"
          type  = "PLAINTEXT"
        } 

        environment_variable {
          name  = "FIX_ABSENT_CHUNKS"
          value = "true"
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
        stream_name = "oracle-validate-chunks-${each.key}"
      }
    }

    vpc_config {
      vpc_id             = local.vpc_config.vpc_id
      subnets            = local.vpc_config.subnet_ids
      security_group_ids = local.vpc_config.security_group_ids
    }

}
