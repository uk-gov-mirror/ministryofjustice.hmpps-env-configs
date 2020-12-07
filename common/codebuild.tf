# main terraform project
module "terraform_package" {
  source = "../modules/codebuild-project"
  name           = "${local.common_name}-terraform-package"
  description    = "${local.common_name}-terraform-package"
  build_timeout  = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = local.tags
  log_group = module.create_loggroup.loggroup_name
  buildspec = templatefile("./templates/terraform/package.yml.tpl", {})
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_type = "LINUX_CONTAINER"
  environment = {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }
  build_image = var.code_build["ansible3_image"]
  image_pull_credentials_type = "SERVICE_ROLE"
  environment_variables = [
    {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  ]
}

module "terraform_version" {
  source = "../modules/codebuild-project"
  name           = "${local.common_name}-terraform-version"
  description    = "${local.common_name}-terraform-version"
  build_timeout  = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = local.tags
  log_group = module.create_loggroup.loggroup_name
  buildspec = templatefile("./templates/terraform/version.yml.tpl", {})
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_type = "LINUX_CONTAINER"
  environment = {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }
  build_image = var.code_build["terraform_image"]
  image_pull_credentials_type = "SERVICE_ROLE"
  environment_variables = [
    {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  ]
}

module "terraform_package_ssm" {
  source = "../modules/codebuild-project"
  name           = "${local.common_name}-terraform-ssm-package"
  description    = "${local.common_name}-terraform-ssm-package"
  build_timeout  = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = local.tags
  log_group = module.create_loggroup.loggroup_name
  buildspec = templatefile("./templates/terraform/package-ssm.yml.tpl", {})
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_type = "LINUX_CONTAINER"
  environment = {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }
  build_image = var.code_build["terraform_image"]
  image_pull_credentials_type = "SERVICE_ROLE"
  environment_variables = [
    {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  ]
}

module "terraform_plan" {
  source = "../modules/codebuild-project"
  name           = "${local.common_name}-terraform-plan"
  description    = "${local.common_name}-terraform-plan"
  build_timeout  = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = local.tags
  log_group = module.create_loggroup.loggroup_name
  buildspec = templatefile("./templates/terraform/plan.yml.tpl", {})
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_type = "LINUX_CONTAINER"
  environment = {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }
  build_image = var.code_build["terraform_image"]
  image_pull_credentials_type = "SERVICE_ROLE"
  environment_variables = [
    {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  ]
}

module "terraform_apply" {
  source = "../modules/codebuild-project"
  name           = "${local.common_name}-terraform-apply"
  description    = "${local.common_name}-terraform-apply"
  build_timeout  = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = local.tags
  log_group = module.create_loggroup.loggroup_name
  buildspec = templatefile("./templates/terraform/apply.yml.tpl", {})
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_type = "LINUX_CONTAINER"
  environment = {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }
  build_image = var.code_build["terraform_image"]
  image_pull_credentials_type = "SERVICE_ROLE"
  environment_variables = [
    {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  ]
}

module "ansible_utils" {
  source = "../modules/codebuild-project"
  name           = "${local.common_name}-terraform-ansible"
  description    = "${local.common_name}-terraform-ansible"
  build_timeout  = "30"
  service_role   = aws_iam_role.codebuild.arn
  tags = local.tags
  log_group = module.create_loggroup.loggroup_name
  buildspec = templatefile("./templates/terraform/ansible.yml.tpl", {})
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_type = "LINUX_CONTAINER"
  environment = {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }
  build_image = local.images["ansible3"]
  image_pull_credentials_type = "SERVICE_ROLE"
  environment_variables = [
    {
      name  = "RUNNING_IN_CONTAINER"
      value = "True"
    }
  ]
}
