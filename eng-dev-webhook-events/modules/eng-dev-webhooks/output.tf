output "webhook_info" {
  value = {
    event_log_group_arn    = aws_cloudwatch_log_group.webhook.arn
    lambda_handler_arn     = aws_lambda_function.webhook-handler.arn
    api_gateway_invoke_url = aws_api_gateway_deployment.gh.invoke_url
    event_bus_name         = var.lambda_map["event_bus_name"]
    event_bus_source_id    = var.lambda_map["event_bus_source_id"]
  }
}
