output "codepipeline_webhooks_hmpps_engineering_tools" {
    value = {
        url = aws_codepipeline_webhook.codepipeline_webhooks_hmpps_engineering_tools.url
        id =  aws_codepipeline_webhook.codepipeline_webhooks_hmpps_engineering_tools.id
    }
}
