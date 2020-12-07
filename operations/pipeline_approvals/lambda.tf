data "archive_file" "ssm_slack_lambda_zip" {
  type        = "zip"
  output_path = "files/lambda.zip"
  source {
    content  = file("lambda/lambda.py")
    filename = "lambda.py"
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "sns.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codepipeline:GetPipelineState",
      "codepipeline:PutApprovalResult",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:FilterLogEvents",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "${local.common_name}-terraform-approval"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name   = "${local.common_name}-terraform-approval"
  policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}
