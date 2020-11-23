# dev
resource "aws_codebuild_project" "pipelines" {
  name           = "${local.common_name}-pipelines"
  description    = local.common_name
  build_timeout  = "30"
  queued_timeout = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-pipelines"
    },
  )

  logs_config {
    cloudwatch_logs {
      group_name  = module.create_loggroup.loggroup_name
      stream_name = "${local.common_name}-pipelines"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec-terraform.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["terraform"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
    environment_variable {
      name  = "TASK"
      value = "terraform"
    }
  }
}

# ansible 

resource "aws_codebuild_project" "ansible2" {
  name           = "${local.common_name}-ansible2"
  description    = local.common_name
  build_timeout  = "60"
  queued_timeout = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-ansible2"
    },
  )

  logs_config {
    cloudwatch_logs {
      group_name  = module.create_loggroup.loggroup_name
      stream_name = "${local.common_name}-ansible2"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec-ansible2.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["ansible2"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
    environment_variable {
      name  = "TASK"
      value = "ansible"
    }
  }
}

resource "aws_codebuild_project" "ansible3" {
  name           = "${local.common_name}-ansible3"
  description    = local.common_name
  build_timeout  = "60"
  queued_timeout = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-ansible3"
    },
  )

  logs_config {
    cloudwatch_logs {
      group_name  = module.create_loggroup.loggroup_name
      stream_name = "${local.common_name}-ansible3"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec-ansible.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["ansible3"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
    environment_variable {
      name  = "TASK"
      value = "ansible"
    }
  }
}

# python 3 
resource "aws_codebuild_project" "python3" {
  name           = "${local.common_name}-python3"
  description    = local.common_name
  build_timeout  = "30"
  queued_timeout = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-python3"
    },
  )

  logs_config {
    cloudwatch_logs {
      group_name  = module.create_loggroup.loggroup_name
      stream_name = "${local.common_name}-python3"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/buildspec-python3.yml"
  }

  environment {
    compute_type                = local.compute_type
    image                       = local.images["ansible3"]
    type                        = local.type
    image_pull_credentials_type = "SERVICE_ROLE"
  }
}

# main terraform project
resource "aws_codebuild_project" "terraform_utils" {
  name           = "${local.common_name}-terraform-utils"
  build_timeout  = "30"
  queued_timeout = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = var.tags

  logs_config {
    cloudwatch_logs {
      group_name  = module.create_loggroup.loggroup_name
      stream_name = "${local.common_name}-terraform-utils"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = templatefile("./templates/terraform/buildspec.yml.tpl", {})
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.code_build["terraform_image"]
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  }
}
