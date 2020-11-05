locals {
  artefacts_bucket             = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket              = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn                 = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  name                         = "eng-webhook-events"
  github_oauth_token_ssm_param = "/manually/created/engineering/dev/codepipeline/github/accesstoken"
  #artifact_bucket_kms_key      = "arn:aws:kms:eu-west-2:895523100917:alias/aws/s3"
  webhook_events_payload_file  = "../functions/webhook-events/function.zip"
  webhook_handler_payload_file = "../functions/webhook-handler/function.zip"
  webhook_handler_key          = "lambda/webhook_handler/${filemd5(local.webhook_handler_payload_file)}/function.zip"
  webhook_events_key           = "lambda/webhook_events/${filemd5(local.webhook_events_payload_file)}/function.zip"
}
