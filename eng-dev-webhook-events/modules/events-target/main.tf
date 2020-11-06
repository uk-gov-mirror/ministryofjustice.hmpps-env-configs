#--------------------------------------------------------------------
# Event Rules
#--------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "webhook" {
  name           = var.event_target_map["name"]
  description    = var.event_target_map["name"]
  event_bus_name = var.event_target_map["event_bus_name"]
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.event_target_map["name"])
    },
  )

  event_pattern = <<EOF
{
  "source": [
    "${var.event_target_map["event_source"]}"
  ],
  "detail": {
    "repository": [
      "${var.event_target_map["repository"]}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "webhook" {
  rule      = aws_cloudwatch_event_rule.webhook.name
  target_id = "${var.event_target_map["name"]}-logs"
  arn       = car.event_target_map["event_log_group_arn"]
}

resource "aws_cloudwatch_event_target" "handler" {
  rule      = aws_cloudwatch_event_rule.webhook.name
  target_id = "${var.event_target_map["name"]}-handler"
  arn       = var.event_target_map["lambda_handler_arn"]
  input_transformer {
    input_paths    = { "action" = "$.detail.action", "branch" = "$.detail.source_branch", "repository" = "$.detail.repository" }
    input_template = <<EOF
{
  "pipeline_name": "${var.event_target_map["pipeline_name"]}",
  "branch": <branch>,
  "action": <action>,
  "repository": <repository>,
  "source_key": "${var.event_target_map["source_key"]}"
}
EOF
  }
}
