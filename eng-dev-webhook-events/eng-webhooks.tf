module "eng-dev-webhooks" {
  source                       = "./modules/eng-dev-webhooks"
  artifact_bucket              = local.artefacts_bucket
  github_oauth_token_ssm_param = local.github_oauth_token_ssm_param
  iam_role_codebuild           = local.iam_role_arn
  iam_role_codepipeline        = local.iam_role_arn
  name                         = local.name
  tags                         = var.tags
  lambda_map = {
    webhook_handler_key = local.webhook_handler_key
    webhook_events_key  = local.webhook_events_key
    event_bus_name      = "default"
    event_bus_source_id = "eng.ci.webhooks"
  }
}

resource "aws_s3_bucket_object" "webhook_events" {
  bucket = local.artefacts_bucket
  key    = local.webhook_events_key
  source = local.webhook_events_payload_file
  etag   = filemd5(local.webhook_events_payload_file)
}

resource "aws_s3_bucket_object" "webhook_handler" {
  bucket = local.artefacts_bucket
  key    = local.webhook_handler_key
  source = local.webhook_handler_payload_file
  etag   = filemd5(local.webhook_handler_payload_file)
}

