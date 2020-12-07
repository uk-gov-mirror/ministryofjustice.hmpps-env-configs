module "engineering_slack_alert" {
  source          = "../../modules/sns-lambda"
  name            = "${local.common_name}-terraform-approval-slack"
  lambda_filename = data.archive_file.ssm_slack_lambda_zip.output_path
  lambda_role_arn = aws_iam_role.lambda_exec_role.arn
  lambda_runtime  = "python3.8"
  tags            = local.tags
  environment = {
    environment_name = local.common_name
    slack_channel    = "delius-engineering-pipelines"
  }
  sns_publishers = [{
    type        = "Service"
    identifiers = ["codepipeline.amazonaws.com"]
  }]
}
