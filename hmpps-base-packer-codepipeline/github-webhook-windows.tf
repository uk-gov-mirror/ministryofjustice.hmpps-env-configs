

// https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codepipeline-webhook.html
// https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-webhook-webhookauthconfiguration.html
// https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-webhook-webhookfilterrule.html
// https://www.terraform.io/docs/providers/aws/r/codepipeline_webhook.html

// # Wire the CodePipeline webhook into a GitHub repository for windows AMI builds
resource "github_repository_webhook" "github_repository_webhook_hmpps_base_packer_windows" {
  repository = data.github_repository.hmpps_base_packer.name

  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhooks_hmpps_base_packer_windows.url
    content_type = "json"
    insecure_ssl = false
    secret       = var.github_webhook_secret
  }

  // https://developer.github.com/webhooks/event-payloads/
  events = ["push", "pull_request"]
}

# webhook into codepipeline to build windows AMIs
resource "aws_codepipeline_webhook" "codepipeline_webhooks_hmpps_base_packer_windows" {
  name            = "github-webhooks-hmpps-base-packer-windows"
  authentication  = "GITHUB_HMAC"
  target_action   = local.sourcecode_action_name
  target_pipeline = aws_codepipeline.codepipeline_hmpps_base_packer_windows.name

  authentication_configuration {
    secret_token = var.github_webhook_secret # TF_VAR_github_webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

