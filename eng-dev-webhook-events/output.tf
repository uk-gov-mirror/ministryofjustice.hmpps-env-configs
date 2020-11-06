output "webhook_info" {
  value = {
    event_log_group_arn = aws_cloudwatch_log_group.webhook.arn
    lambda_handler_arn  = aws_lambda_function.webhook-handler.arn
    webhook_invoke_url  = "https://${local.dns_host}/webhook"
    webhook_secret_key  = local.webhook_secret_key
    event_bus_name      = local.event_bus_name
    event_bus_source_id = local.event_bus_source_id
  }
}
