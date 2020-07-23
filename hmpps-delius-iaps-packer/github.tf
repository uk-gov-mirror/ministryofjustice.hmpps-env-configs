# https://www.terraform.io/docs/providers/aws/r/codebuild_webhook.html
# https://docs.aws.amazon.com/codebuild/latest/userguide/sample-github-pull-request.html

resource "aws_codebuild_webhook" "github_webhooks_hmpps_delius_iaps_packer" {
  project_name = aws_codebuild_project.hmpps_delius_iaps_packer_ami.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED,PULL_REQUEST_MERGED"
    }
  }
}
