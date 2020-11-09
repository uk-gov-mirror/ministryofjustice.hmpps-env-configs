# common
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "aws-migration-pipelines/common/terraform.tfstate"
    region = var.region
  }
}

# vpc
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "github_ip_ranges" "github" {}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_ssm_parameter" "github_oauth_token" {
  name = local.github_oauth_token_ssm_param
}

#-------------------------------------------------------------
### Getting ACM Cert
#-------------------------------------------------------------
data "aws_acm_certificate" "cert" {
  domain      = "*.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# Policies
data "aws_iam_policy_document" "webhook_acl" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.webhook.arn, "${aws_s3_bucket.webhook.arn}/*"]
    actions = [
      "s3:GetObject"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.webhook.arn, "${aws_s3_bucket.webhook.arn}/*"]
    actions = [
      "s3:PutObject"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.lb_account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "codepipeline:CreatePipeline",
      "codepipeline:DeletePipeline",
      "codepipeline:GetPipelineState",
      "codepipeline:ListPipelines",
      "codepipeline:GetPipeline",
      "codepipeline:UpdatePipeline",
      "codepipeline:StartPipelineExecution",
      "iam:PassRole",
      "events:PutEvents",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:ssm:*:*:parameter/manually/created/engineering/dev/codepipeline/github/accesstoken",
      "arn:aws:ssm:*:*:parameter/codepipeline/webhooks/secret"
    ]
    actions = [
      "ssm:GetParameter",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:ssm:*:*:parameter/ci/webhooks/*"]
    actions = [
      "ssm:PutParameter",
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
