#resource "github_repository_webhook" "repo" {
#  repository = var.repo_name
#  active     = true
#  events     = ["push"]
#
#  configuration {
#    url          = aws_api_gateway_deployment.gh.invoke_url
#    content_type = "application/json"
#    insecure_ssl = false
#  }
#}

#--------------------------------------------------------------------
# API Gateway
#--------------------------------------------------------------------

locals {
  emitter_function_name = "${var.name}-emitter"
  handler_function_name = "${var.name}-handler"
}

resource "aws_api_gateway_rest_api" "gh" {
  name        = "${var.name}-gw"
  description = "Webhook to catch GitHub events"
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "${var.name}-gw")
    },
  )
}

resource "aws_api_gateway_method" "webhooks" {
  rest_api_id   = aws_api_gateway_rest_api.gh.id
  resource_id   = aws_api_gateway_rest_api.gh.root_resource_id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.X-GitHub-Event"    = true
    "method.request.header.X-GitHub-Delivery" = true
  }
}

resource "aws_api_gateway_integration" "webhooks" {
  rest_api_id             = aws_api_gateway_rest_api.gh.id
  resource_id             = aws_api_gateway_rest_api.gh.root_resource_id
  http_method             = aws_api_gateway_method.webhooks.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  ###uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
  uri = aws_lambda_function.lambda.invoke_arn

  request_parameters = {
    "integration.request.header.X-GitHub-Event"  = "method.request.header.X-GitHub-Event"
    "integration.request.header.X-Hub-Signature" = "method.request.header.X-Hub-Signature"
  }

  request_templates = {
    "application/json" = <<JSON
{
  "body" : $input.json('$'),
  "header" : {
    "X-GitHub-Event": "$input.params('X-GitHub-Event')",
    "X-GitHub-Delivery": "$input.params('X-GitHub-Delivery')",
    "X-Hub-Signature": "$input.params('X-Hub-Signature')",
    "X-Hub-Signature-256": "$input.params('X-Hub-Signature-256')
  }
}
JSON

  }
}

resource "aws_api_gateway_integration_response" "webhook" {
  rest_api_id = aws_api_gateway_rest_api.gh.id
  resource_id = aws_api_gateway_rest_api.gh.root_resource_id
  http_method = aws_api_gateway_integration.webhooks.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "$input.path('$')"
  }

  response_parameters = {
    "method.response.header.Content-Type"                = "integration.response.header.Content-Type"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  selection_pattern = ".*"
}

resource "aws_api_gateway_method_response" "method" {
  rest_api_id = aws_api_gateway_rest_api.gh.id
  resource_id = aws_api_gateway_rest_api.gh.root_resource_id
  http_method = aws_api_gateway_method.webhooks.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type"                = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_deployment" "gh" {
  depends_on  = [aws_api_gateway_integration.webhooks]
  rest_api_id = aws_api_gateway_rest_api.gh.id
  stage_name  = var.name
}

#--------------------------------------------------------------------
# Lambda webhook events
#--------------------------------------------------------------------

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.gh.id}/*/POST/"
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "${var.name}-lambda")
    },
  )

}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_policy" "lambda" {
  name        = "${var.name}-lambda"
  path        = "/"
  description = "Allows Lambda to manage temporary CodePipeline projects for branches"
  policy      = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "lambda" {
  s3_bucket     = var.artifact_bucket
  s3_key        = var.lambda_map["webhook_events_key"]
  handler       = "main.lambda_handler"
  function_name = local.emitter_function_name
  role          = aws_iam_role.lambda.arn
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  runtime       = "python3.7"
  environment {
    variables = {
      EVENT_BUS_NAME      = var.lambda_map["event_bus_name"],
      EVENT_BUS_SOURCE_ID = var.lambda_map["event_bus_source_id"]
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", local.emitter_function_name)
    },
  )
}

#--------------------------------------------------------------------
# Lambda webhook handler
#--------------------------------------------------------------------


resource "aws_lambda_function" "webhook-handler" {
  s3_bucket     = var.artifact_bucket
  s3_key        = var.lambda_map["webhook_handler_key"]
  handler       = "main.lambda_handler"
  function_name = local.handler_function_name
  role          = aws_iam_role.lambda.arn
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  runtime       = "python3.7"


  environment {
    variables = {
      GITHUB_SSM_PARAM = var.github_oauth_token_ssm_param
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", local.handler_function_name)
    },
  )
}

#--------------------------------------------------------------------
# Event Rules
#--------------------------------------------------------------------
# resource "aws_cloudwatch_event_rule" "webhook" {
#   name        = "eng-ci-webhook-rule"
#   description = "eng-ci-webhook-rule"
#   tags = merge(
#     var.tags,
#     {
#       "Name" = format("%s", "eng-ci-webhook-rule")
#     },
#   )

#   event_pattern = <<EOF
# {
#   "source": [
#     "eng.ci.webhooks"
#   ],
#   "detail": {
#     "repository": [
#       "hmpps-delius-alfresco-shared-terraform"
#     ]
#   }
# }
# EOF
# }

# resource "aws_cloudwatch_event_target" "webhook" {
#   rule      = aws_cloudwatch_event_rule.webhook.name
#   target_id = "ci_webhook_events"
#   arn       = aws_cloudwatch_log_group.webhook.arn
# }

# resource "aws_cloudwatch_event_target" "handler" {
#   rule      = aws_cloudwatch_event_rule.webhook.name
#   target_id = "ci-webhook-handler"
#   arn       = aws_lambda_function.webhook-handler.arn
#   input_transformer {
#     input_paths    = { "action" = "$.detail.action", "branch" = "$.detail.source_branch", "repository" = "$.detail.repository" }
#     input_template = <<EOF
# {
#   "pipeline_name": "alf-infra-build-alfresco-dev",
#   "branch": <branch>,
#   "action": <action>,
#   "repository": <repository>,
#   "source_key": 0
# }
# EOF
#   }
# }


resource "aws_cloudwatch_log_group" "webhook" {
  name              = "/aws/events/${var.name}"
  retention_in_days = var.retention_in_days
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/events/${var.name}")
    },
  )
}

resource "aws_cloudwatch_log_group" "emitter" {
  name              = "/aws/lambda/${local.emitter_function_name}"
  retention_in_days = var.retention_in_days
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/lambda/${local.emitter_function_name}")
    },
  )
}

resource "aws_cloudwatch_log_group" "handler" {
  name              = "/aws/lambda/${local.handler_function_name}"
  retention_in_days = var.retention_in_days
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/lambda/${local.handler_function_name}")
    },
  )
}
