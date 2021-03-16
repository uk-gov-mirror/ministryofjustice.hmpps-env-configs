

resource "aws_codebuild_project" "hmpps_base_packer_amis" {

  for_each = local.codebuild_project_names_all

  name           = each.value
  description    = "${local.common_name} Packer AMI Builder for ${each.value}"
  build_timeout  = local.build_timeout
  queued_timeout = local.queued_timeout

  service_role = local.service_role
  tags = merge(
    local.tags,
    {
      "Name" = each.value
    }
  )

  artifacts {
    type = local.build_artifacts.type
  }

  environment {
    compute_type                = local.build_environment_spec.compute_type
    image                       = local.build_environment_spec.images["packer"]
    type                        = local.build_environment_spec.type
    image_pull_credentials_type = local.build_environment_spec.image_pull_credentials_type
    privileged_mode             = true

    # dynamic "environment_variable" {
    #   for_each = local.build_environment_spec.environment_variables
    #   content {
    #     key   = environment_variable.key
    #     value = environment_variable.value
    #   }
    # }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = local.group_name
      stream_name = each.value
    }
  }

  source {
    type      = local.build_source.type
    buildspec = "buildspec_${each.key}.yml"
  }

  vpc_config {
    vpc_id             = local.vpc_config.vpc_id
    subnets            = local.vpc_config.subnet_ids
    security_group_ids = local.vpc_config.security_group_ids
  }

}

