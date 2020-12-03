output "info" {
  value = {
    iam_role_arn = aws_iam_role.lambda_exec_role.arn
  }
}
