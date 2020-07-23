output "codepipeline_webhooks_hmpps_base_packer_linux_url" {
    value = {
        url = aws_codepipeline_webhook.codepipeline_webhooks_hmpps_base_packer_linux.url
        id =  aws_codepipeline_webhook.codepipeline_webhooks_hmpps_base_packer_linux.id
    }
}

output "codepipeline_webhooks_hmpps_base_packer_windows_url" {
    value = {
        url = aws_codepipeline_webhook.codepipeline_webhooks_hmpps_base_packer_windows.url
        id =  aws_codepipeline_webhook.codepipeline_webhooks_hmpps_base_packer_windows.id
    }
}