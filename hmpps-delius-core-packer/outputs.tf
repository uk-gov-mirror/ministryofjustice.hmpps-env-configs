output "codepipeline_webhooks_hmpps_delius_core_packer" {
    value = {
        url = aws_codepipeline_webhook.codepipeline_webhooks_hmpps_delius_core_packer.url
        id =  aws_codepipeline_webhook.codepipeline_webhooks_hmpps_delius_core_packer.id
    }
}
