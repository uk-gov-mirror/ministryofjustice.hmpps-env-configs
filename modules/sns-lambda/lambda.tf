resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.name
  role             = var.lambda_role_arn
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  filename         = var.lambda_filename
  source_code_hash = filebase64sha256(var.lambda_filename)
  tags             = merge(var.tags, { Name = var.name })
  timeout          = 30
  environment {
    variables = var.environment
  }
}

resource "aws_cloudwatch_log_group" "emitter" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 7
  tags = var.tags
}
