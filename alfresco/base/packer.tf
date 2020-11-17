data "template_file" "packer_role_assume" {
  template = file("./templates/assume_packer.tmpl")
  vars     = {}
}

resource "aws_iam_role" "packer" {
  name               = "alfresco-ami-packer-builder"
  assume_role_policy = data.template_file.packer_role_assume.rendered
  tags = merge(
    local.tags,
    {
      "Name" = "alfresco-ami-packer-builder"
    },
  )
}

resource "aws_iam_instance_profile" "packer" {
  name = "test_profile"
  role = aws_iam_role.packer.name
}

data "template_file" "packer_pol" {
  template = file("./templates/packer_pol.tmpl")
}
resource "aws_iam_policy" "packer_role" {
  name        = "alfresco-ami-packer-builder-policy"
  path        = "/service-role/"
  description = "Policy used for Packer AMI Builder"
  policy      = data.template_file.packer_pol.rendered
}

resource "aws_iam_policy_attachment" "packer" {
  name       = aws_iam_role.packer.name
  policy_arn = aws_iam_policy.packer_role.arn
  roles      = [aws_iam_role.packer.id]
}

resource "aws_codebuild_webhook" "ami" {
  project_name = aws_codebuild_project.ami.name
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = "^refs/heads/*"
    }
  }
}

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

  logs_config {
    cloudwatch_logs {
      group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
      stream_name = "alfresco-ami-packer"
    }
  }

  artifacts {
    type      = "S3"
    name      = "alfresco_terraform_code.zip"
    location  = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
    path      = local.release_project
    packaging = "ZIP"
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.code_build["github_org"]}/${var.code_build["packer_repo"]}"
    buildspec = templatefile("./templates/packer_buildspec.yml.tpl", { iam_profile_name = aws_iam_instance_profile.packer.name })

    auth {
      type     = "OAUTH"
      resource = data.aws_ssm_parameter.jenkins_token.value
    }
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

