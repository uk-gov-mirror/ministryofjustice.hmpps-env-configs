module "security-access-terraform-components" {
  source = "./modules/events-target"
  event_target_map = {
    name                = "security-access-terraform-components"
    repository          = "hmpps-security-access-terraform"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}
