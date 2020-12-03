output "topic_arn" { value = aws_sns_topic.topic.arn }
output "lambda_arn" { value = aws_lambda_function.lambda.arn }