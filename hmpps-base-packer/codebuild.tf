resource "aws_codebuild_project" "hmpps_base_packer_ami" {
  name           = local.common_name
  description    = "${local.common_name} Packer AMI Builder"
  build_timeout  = local.build_timeout
  queued_timeout = local.queued_timeout

  service_role   = local.service_role
  tags = merge(
    local.tags,
    {
      "Name" = "hmpps_base_packer_ami_bake"
    },
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
    
    dynamic "environment_variable" {
      for_each = local.build_environment_spec.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = local.group_name
      stream_name = local.stream_name
    }
  }

  source {  
    type                = "GITHUB"
    location            = local.build_source.location
    git_clone_depth     = local.build_source.git_clone_depth
    insecure_ssl        = local.build_source.insecure_ssl
    report_build_status = local.build_source.report_build_status

    auth {
      type     = "OAUTH"
    }

    git_submodules_config {
      fetch_submodules = local.build_source.git_submodules_config.fetch_submodules
    }

    buildspec = local.build_source.buildspec
  }

  vpc_config {
    vpc_id             = local.vpc_config.vpc_id
    subnets            = local.vpc_config.subnet_ids
    security_group_ids = local.vpc_config.security_group_ids
  }

}

