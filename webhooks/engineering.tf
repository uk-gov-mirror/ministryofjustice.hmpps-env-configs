module "eng-lambda-functions-builder" {
  source = "./modules/events-target"
  event_target_map = {
    name                = "eng-lambda-functions-builder"
    repository          = "hmpps-engineering-lambda-functions"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}

module "create-pipelines-eng-dev" {
  source = "./modules/events-target"
  event_target_map = {
    name                = "create-pipelines-eng-dev"
    repository          = "hmpps-engineering-pipelines"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}

module "create-pipelines-hmpps-base-packer" {
  source = "./modules/events-target"
  event_target_map = {
    name                = "create-pipelines-hmpps-base-packer"
    repository          = "hmpps-base-packer"
    source_key          = "0"
    event_source        = local.webhook_info["dipatcher_bus_source_id"]
    event_log_group_arn = local.webhook_info["event_log_group_arn"]
    lambda_handler_arn  = local.webhook_info["lambda_handler_arn"]
    webhook_invoke_url  = local.webhook_info["webhook_invoke_url"]
    webhook_secret_key  = local.webhook_secret_key
  }
}
