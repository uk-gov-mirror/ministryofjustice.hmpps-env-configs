# https://www.terraform.io/docs/providers/aws/r/codebuild_webhook.html
# https://docs.aws.amazon.com/codebuild/latest/userguide/sample-github-pull-request.html

resource "aws_codebuild_webhook" "github_webhooks_hmpps_dss_core_docker" {
  project_name = aws_codebuild_project.hmpps_delius_dss_offloc_docker.name

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
