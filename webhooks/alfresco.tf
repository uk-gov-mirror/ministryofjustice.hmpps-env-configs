module "alf-infra-build-alfresco-dev" {
  source = "./modules/events-target"
  event_target_map = {
    name                = "alf-infra-build-alfresco-dev"
    repository          = "hmpps-delius-alfresco-shared-terraform"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}

module "alf-packer-build-alfresco-ami" {
  source          = "./modules/events-target"
  event_rule_name = "alf-packer-build-alfresco-ami"
  event_target_map = {
    name                = "alf-packer-builds-pipeline"
    repository          = "hmpps-alfresco-packer"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}

module "alf-packer-build-solr-ami" {
  source          = "./modules/events-target"
  event_rule_name = "alf-packer-build-solr-ami"
  event_target_map = {
    name                = "alf-packer-builds-pipeline"
    repository          = "hmpps-solr-packer"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}

module "alf-network-build-alfresco-dev" {
  source = "./modules/events-target"
  event_target_map = {
    name                = "alf-network-build-alfresco-dev"
    repository          = "hmpps-network-terraform-alfresco"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}
