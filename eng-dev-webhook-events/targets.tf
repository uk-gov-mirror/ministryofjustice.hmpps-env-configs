#--------------------------------------------------------------------
# Event Rules
#--------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "dispatcher" {
  name        = local.dispatcher_function_name
  description = local.dispatcher_function_name
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", local.dispatcher_function_name)
    },
  )

  event_pattern = <<EOF
{
  "source": [
    "${local.event_bus_source_id}"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "dispatcher_lambda" {
  rule      = aws_cloudwatch_event_rule.dispatcher.name
  target_id = local.dispatcher_function_name
  arn       = aws_lambda_function.dispatcher.arn
}
