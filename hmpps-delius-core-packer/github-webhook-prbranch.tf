
// # Wire the CodePipeline webhook into a GitHub repository for linux AMI builds
resource "github_repository_webhook" "github_repository_webhook_hmpps_delius_core_packer_prbranch" {
  repository = data.github_repository.hmpps_base_packer.name

  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhooks_hmpps_delius_core_packer_prbranch.url
    content_type = "json"
    insecure_ssl = false
    secret = var.github_webhook_secret  
  }

  // https://developer.github.com/webhooks/event-payloads/
  events = ["push", "pull_request"]
}

// https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codepipeline-webhook.html
// https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-webhook-webhookauthconfiguration.html
// https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-webhook-webhookfilterrule.html
// https://www.terraform.io/docs/providers/aws/r/codepipeline_webhook.html

# webhook into codepipeline to build linux AMIs
resource "aws_codepipeline_webhook" "codepipeline_webhooks_hmpps_delius_core_packer_prbranch" {
  name            = "github-webhooks-hmpps-delius-corer-packer-prbranch"
  authentication  = "GITHUB_HMAC"
  target_action   = local.sourcecode_action_name
  target_pipeline = aws_codepipeline.codepipeline_hmpps_delius_core_packer_prbranch.name

  authentication_configuration {
    secret_token = var.github_webhook_secret   # TF_VAR_github_webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

}