###############################################
# CloudWatch
###############################################

module "create_loggroup" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/cloudwatch/loggroup?ref=terraform-0.12"
  log_group_path           = local.common_name
  loggroupname             = "logs"
  cloudwatch_log_retention = var.cloudwatch_log_retention
  kms_key_id               = aws_kms_key.kms.arn
  tags                     = local.tags
}


module "create_loggroup_packer_ami_builder" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/cloudwatch/loggroup?ref=terraform-0.12"
  log_group_path           = local.common_name
  loggroupname             = "packerbuilder-logs"
  cloudwatch_log_retention = var.cloudwatch_log_retention
  kms_key_id               = aws_kms_key.kms.arn
  tags                     = local.tags
}

module "create_loggroup_docker_images_builder" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/cloudwatch/loggroup?ref=terraform-0.12"
  log_group_path           = local.common_name
  loggroupname             = "dockerimagebuilder-logs"
  cloudwatch_log_retention = var.cloudwatch_log_retention
  kms_key_id               = aws_kms_key.kms.arn
  tags                     = local.tags
}