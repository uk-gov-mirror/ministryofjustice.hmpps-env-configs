data "archive_file" "ssm_slack_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/files/lambda.zip"
  source {
    content  = file("${path.module}/lambda/lambda.py")
    filename = "lambda.py"
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:FilterLogEvents",
      "codepipeline:GetPipelineState",
      "codepipeline:PutApprovalResult",
      "codebuild:BatchGetBuilds"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "${var.environment_name}-terraform-approval-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name   = "${var.environment_name}-terraform-approval-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}
