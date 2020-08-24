
provider "github" {
  //token        = GITHUB_TOKEN environment variable
  organization = "ministryofjustice"
}

// # reference to the target repo we're creating a github hook on
data "github_repository" "hmpps_delius_core_packer" {
  full_name = "ministryofjustice/hmpps-delius-core-packer"
}


# https://www.terraform.io/docs/providers/aws/r/codebuild_webhook.html
# https://docs.aws.amazon.com/codebuild/latest/userguide/sample-github-pull-request.html

resource "aws_codebuild_webhook" "github_webhooks_hmpps_delius_core_packer_19c" {
  project_name = aws_codebuild_project.hmpps_delius_core_packer_19c_ami.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH, PULL_REQUEST_CREATED, PULL_REQUEST_UPDATED, PULL_REQUEST_REOPENED"   # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook#filter_group
    }

    filter {
      type    = "HEAD_REF"
      pattern = "ALS-890"
    }
  }
}




// # Wire the CodePipeline webhook into a GitHub repository for linux AMI builds
resource "github_repository_webhook" "github_repository_webhook_hmpps_delius_core_packer_19c" {
  repository = data.github_repository.hmpps_delius_core_packer.name

  configuration {
    url          = aws_codebuild_webhook.github_webhooks_hmpps_delius_core_packer_19c.url
    content_type = "json"
    insecure_ssl = false
    secret = var.github_webhook_secret  
  }

  // https://developer.github.com/webhooks/event-payloads/
  events = ["push", "pull_request"]
}