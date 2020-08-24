# https://www.terraform.io/docs/providers/aws/r/codebuild_webhook.html
# https://docs.aws.amazon.com/codebuild/latest/userguide/sample-github-pull-request.html

resource "aws_codebuild_webhook" "github_webhooks_hmpps_nextcloud_packer" {
  project_name = aws_codebuild_project.hmpps_nextcloud_packer_ami.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "master"
    }
  }
}
