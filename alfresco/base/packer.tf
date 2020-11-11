resource "aws_codebuild_project" "ami" {
  name           = "alfresco-ami-packer"
  description    = "alfresco-ami-packer"
  build_timeout  = "45"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags = merge(
    local.tags,
    {
      "Name" = "alfresco-ami-packer"
    },
  )
  count = length(local.tasks_list)

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = "alfresco-ami-packer"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["packer"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true

    environment_variable {
      name  = "DOCKER_CERTS_DIR"
      value = "/opt/docker"
    }
  }
  vpc_config {
    vpc_id  = local.vpc_id
    subnets = local.private_subnet_ids

    security_group_ids = [
      aws_security_group.alfresco.id,
    ]
  }
}

