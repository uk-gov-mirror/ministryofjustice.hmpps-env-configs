resource "aws_sns_topic" "topic" {
  name = var.name
  lambda_failure_feedback_role_arn         = var.lambda_role_arn
  lambda_success_feedback_role_arn         = var.lambda_role_arn 
  tags = merge(var.tags, { Name = var.name })
}

data "aws_iam_policy_document" "sns_policy_doc" {
  statement {
    sid       = "AllowPublish"
    effect    = "Allow"
    resources = [aws_sns_topic.topic.arn]
    actions   = ["sns:Publish"]
    dynamic "principals" {
      for_each = var.sns_publishers
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }
  }
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.sns_policy_doc.json
}

resource "aws_sns_topic_subscription" "subscription" {
  protocol  = "lambda"
  topic_arn = aws_sns_topic.topic.arn
  endpoint  = aws_lambda_function.lambda.arn
}
