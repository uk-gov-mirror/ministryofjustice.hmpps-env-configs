module "trigger-dev-builds" {
  source = "../../../modules/codebuild-trigger"
  name           = local.trigger_project
  description    = "${local.trigger_project}-dev-deployments"
  artefacts_bucket = local.artefacts_bucket
  build_timeout  = "10"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  tags = local.tags
  log_group = local.log_group_name
  buildspec = templatefile("./templates/trigger-buildspec.yml.tpl", {})
  location  = "https://github.com/ministryofjustice/hmpps-delius-alfresco-shared-terraform"
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_type = "LINUX_CONTAINER"
  build_image = var.code_build["python_image"]
  image_pull_credentials_type = "SERVICE_ROLE"
  pattern = "refs/tags/*"
}
