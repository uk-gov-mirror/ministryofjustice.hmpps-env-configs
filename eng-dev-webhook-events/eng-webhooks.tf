#--------------------------------------------------------------------
# Lambda webhook handler
#--------------------------------------------------------------------
# module "eng-dev-webhooks" {
#   source                       = "./modules/eng-dev-webhooks"
#   artifact_bucket              = local.artefacts_bucket
#   github_oauth_token_ssm_param = local.github_oauth_token_ssm_param
#   iam_role_codebuild           = local.iam_role_arn
#   iam_role_codepipeline        = local.iam_role_arn
#   name                         = local.name
#   tags                         = var.tags
#   lambda_map = {
#     webhook_handler_key = local.webhook_handler_key
#     webhook_events_key  = local.webhook_events_key
#     event_bus_name      = "default"
#     event_bus_source_id = "eng.ci.webhooks"
#   }
# }

resource "aws_security_group" "webhook" {
  name        = local.name
  description = "security group for ${local.name}"
  vpc_id      = local.vpc_id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.webhook.id
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = data.github_ip_ranges.github.hooks
  description       = "${local.name}-https"
}

resource "aws_security_group_rule" "https_out" {
  security_group_id = aws_security_group.webhook.id
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.name}-https"
}

resource "aws_lb" "webhook" {
  name                       = local.name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.webhook.id]
  subnets                    = local.public_subnet_ids
  enable_deletion_protection = false
  tags                       = var.tags

  lifecycle {
    create_before_destroy = true
  }
  access_logs {
    bucket  = aws_s3_bucket.webhook.id
    prefix  = local.name
    enabled = true
  }
}

resource "aws_lb_target_group" "webhook" {
  name        = local.name
  target_type = "lambda"
  tags        = var.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.webhook.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "webhook" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webhook.arn
  }

  condition {
    path_pattern {
      values = ["/webhook"]
    }
  }
}

resource "aws_route53_record" "webhook" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = local.dns_host
  type    = "A"

  alias {
    name                   = aws_lb.webhook.dns_name
    zone_id                = aws_lb.webhook.zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket" "webhook" {
  bucket = local.name
  acl    = "private"
  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = 60
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_object" "webhook_events" {
  bucket = aws_s3_bucket.webhook.id
  key    = local.webhook_events_key
  source = local.webhook_events_payload_file
  etag   = filemd5(local.webhook_events_payload_file)
}

resource "aws_s3_bucket_object" "webhook_handler" {
  bucket = aws_s3_bucket.webhook.id
  key    = local.webhook_handler_key
  source = local.webhook_handler_payload_file
  etag   = filemd5(local.webhook_handler_payload_file)
}

resource "aws_s3_bucket_policy" "webhook" {
  bucket = aws_s3_bucket.webhook.id
  policy = data.aws_iam_policy_document.webhook_acl.json
}

#--------------------------------------------------------------------
# Lambda webhook events
#--------------------------------------------------------------------

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "${local.name}-lambda")
    },
  )

}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_policy" "lambda" {
  name        = "${local.name}-lambda"
  path        = "/"
  description = "Allows Lambda to manage temporary CodePipeline projects for branches"
  policy      = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "lambda" {
  s3_bucket     = aws_s3_bucket.webhook.id
  s3_key        = local.webhook_events_key
  handler       = "main.lambda_handler"
  function_name = local.emitter_function_name
  role          = aws_iam_role.lambda.arn
  memory_size   = 256
  timeout       = 60
  runtime       = "python3.7"
  environment {
    variables = {
      EVENT_BUS_NAME               = local.event_bus_name,
      EVENT_BUS_SOURCE_ID          = local.event_bus_source_id
      WEBHOOK_SECRET_KEY_SSM_PARAM = local.webhook_secret_key
      WEBHOOK_CHECK_SIGNATURES     = "no"
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", local.emitter_function_name)
    },
  )
  depends_on = [aws_s3_bucket_object.webhook_events]
}

resource "aws_lambda_function" "webhook-handler" {
  s3_bucket     = aws_s3_bucket.webhook.id
  s3_key        = local.webhook_handler_key
  handler       = "main.lambda_handler"
  function_name = local.handler_function_name
  role          = aws_iam_role.lambda.arn
  memory_size   = 256
  timeout       = 60
  runtime       = "python3.7"


  environment {
    variables = {
      GITHUB_SSM_PARAM = local.github_oauth_token_ssm_param
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", local.handler_function_name)
    },
  )
  depends_on = [aws_s3_bucket_object.webhook_handler]
}

resource "aws_cloudwatch_log_group" "webhook" {
  name              = "/aws/events/${local.name}"
  retention_in_days = 7
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/events/${local.name}")
    },
  )
}

resource "aws_cloudwatch_log_group" "emitter" {
  name              = "/aws/lambda/${local.emitter_function_name}"
  retention_in_days = 7
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/lambda/${local.emitter_function_name}")
    },
  )
}

resource "aws_cloudwatch_log_group" "handler" {
  name              = "/aws/lambda/${local.handler_function_name}"
  retention_in_days = 7
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "/aws/lambda/${local.handler_function_name}")
    },
  )
}

resource "aws_lb_target_group_attachment" "webhook" {
  target_group_arn = aws_lb_target_group.webhook.arn
  target_id        = aws_lambda_function.lambda.arn
  depends_on       = [aws_lambda_permission.lambda]
}
