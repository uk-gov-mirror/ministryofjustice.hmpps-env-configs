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

resource "aws_api_gateway_rest_api" "gh" {
  name        = "${var.name}-codepipeline"
  description = "Webhook to catch GitHub events"
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "${var.name}-codepipeline")
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
    "integration.request.header.X-GitHub-Event" = "method.request.header.X-GitHub-Event"
  }

  request_templates = {
    "application/json" = <<JSON
{
  "body" : $input.json('$'),
  "header" : {
    "X-GitHub-Event": "$input.params('X-GitHub-Event')",
    "X-GitHub-Delivery": "$input.params('X-GitHub-Delivery')"
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
  stage_name  = "eng-dev-webhook"
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

resource "aws_lambda_function" "lambda" {
  s3_bucket     = var.artifact_bucket
  s3_key        = var.lambda_map["webhook_events_key"]
  handler       = "main.lambda_handler"
  function_name = var.name
  role          = aws_iam_role.lambda.arn
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  runtime       = "python3.7"
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-codepipeline-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "${var.name}-codepipeline-lambda")
    },
  )

}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_policy" "lambda" {
  name        = "${var.name}-codepipeline-lambda"
  path        = "/"
  description = "Allows Lambda to manage temporary CodePipeline projects for branches"
  policy      = data.aws_iam_policy_document.lambda_policy.json
}

#--------------------------------------------------------------------
# Lambda webhook handler
#--------------------------------------------------------------------


resource "aws_lambda_function" "webhook-handler" {
  s3_bucket     = var.artifact_bucket
  s3_key        = var.lambda_map["webhook_handler_key"]
  handler       = "main.lambda_handler"
  function_name = "eng-webhook-handler"
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
      "Name" = format("%s", "eng-webhook-handler")
    },
  )
}

#--------------------------------------------------------------------
# Event Rules
#--------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "webhook" {
  name        = "eng-ci-webhook-rule"
  description = "eng-ci-webhook-rule"
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "eng-ci-webhook-rule")
    },
  )

  event_pattern = <<EOF
{
  "source": [
    "eng.ci.webhooks"
  ],
  "detail": {
    "repository": [
      "hmpps-delius-alfresco-shared-terraform"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "webhook" {
  rule      = aws_cloudwatch_event_rule.webhook.name
  target_id = "ci_webhook_events"
  arn       = aws_cloudwatch_log_group.webhook.arn
}

resource "aws_cloudwatch_event_target" "handler" {
  rule      = aws_cloudwatch_event_rule.webhook.name
  target_id = "ci-webhook-handler"
  arn       = aws_lambda_function.webhook-handler.arn
  input_transformer {
    input_paths    = { "action" = "$.detail.action", "branch" = "$.detail.source_branch", "repository" = "$.detail.repository" }
    input_template = <<EOF
{
  "pipeline_name": "alf-infra-build-alfresco-dev",
  "branch": <branch>,
  "action": <action>,
  "repository": <repository>
}
EOF
  }
}


resource "aws_cloudwatch_log_group" "webhook" {
  name              = "/aws/events/eng-webhook-events"
  retention_in_days = var.retention_in_days
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/events/eng-webhook-events")
    },
  )
}

resource "aws_cloudwatch_log_group" "eng-webhook-events" {
  name              = "/aws/lambda/eng-webhook-events"
  retention_in_days = var.retention_in_days
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/lambda/eng-webhook-events")
    },
  )
}

resource "aws_cloudwatch_log_group" "eng-webhook-handler" {
  name              = "/aws/lambda/eng-webhook-handler"
  retention_in_days = var.retention_in_days
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/lambda/eng-webhook-handler")
    },
  )
}


#--------------------------------------------------------------------
# CodePipeline & CodeBuild
#--------------------------------------------------------------------

#resource "aws_codepipeline" "codepipeline" {
#  name     = var.name
#  role_arn = var.iam_role_codepipeline
#
#  artifact_store {
#    location = var.artifact_bucket
#    type     = "S3"
#
#    encryption_key {
#      id   = var.artifact_bucket_kms_key
#      type = "KMS"
#    }
#  }
#
#  stage {
#    name = "Source"
#
#    action {
#      name             = "Source"
#      category         = "Source"
#      owner            = "ThirdParty"
#      provider         = "GitHub"
#      version          = "1"
#      output_artifacts = ["source"]
#
#      configuration = {
#        Owner      = var.github_organization
#        Repo       = var.github_repository
#        Branch     = var.github_branch_default
#        OAuthToken = data.aws_ssm_parameter.github_oauth_token.value
#      }
#    }
#  }
#
#  stage {
#    name = "Build"
#
#    action {
#      name            = "Build"
#      category        = "Build"
#      owner           = "AWS"
#      provider        = "CodeBuild"
#      input_artifacts = ["source"]
#      version         = "1"
#
#      configuration = {
#        ProjectName = aws_codebuild_project.codebuild.name
#      }
#    }
#  }
#}
#
#resource "aws_codebuild_project" "codebuild" {
#  name          = var.name
#  description   = "Build step for ${var.github_organization}/${var.github_repository}"
#  build_timeout = "10"
#  service_role  = var.iam_role_codebuild
#
#  artifacts {
#    type = "CODEPIPELINE"
#  }
#
#  environment {
#    compute_type    = var.codebuild_compute_type
#    image           = var.codebuild_image
#    type            = var.codebuild_os
#    privileged_mode = var.codebuild_privileged_mode
#  }
#
#  source {
#    type = "CODEPIPELINE"
#  }
#}
