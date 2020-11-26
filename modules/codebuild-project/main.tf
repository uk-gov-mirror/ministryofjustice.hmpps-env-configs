resource "aws_codebuild_project" "project" {
  name           = var.name
  description    = var.description
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout 
  service_role   = var.service_role
  tags = var.tags

  logs_config {
    cloudwatch_logs {
      group_name  = var.log_group
      stream_name = var.name
    }
  }

  artifacts {
    type = var.artifact_type
  }

  cache {
    type     = lookup(local.cache, "type", null)
    location = lookup(local.cache, "location", null)
    modes    = lookup(local.cache, "modes", null)
  }

  source {
    type      = var.source_type
    buildspec = var.buildspec
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = var.build_type
    privileged_mode = var.privileged_mode
    image_pull_credentials_type = var.image_pull_credentials_type

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_config) > 0 ? [""] : []
    content {
      vpc_id             = lookup(var.vpc_config, "vpc_id", null)
      subnets            = lookup(var.vpc_config, "subnets", null)
      security_group_ids = lookup(var.vpc_config, "security_group_ids", null)
    }
  }
}
