data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_ssm_parameter" "github_oauth_token" {
  name = var.github_oauth_token_ssm_param
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
    effect    = "Allow"
    resources = ["arn:aws:ssm:*:*:parameter/manually/created/engineering/dev/codepipeline/github/accesstoken"]
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
