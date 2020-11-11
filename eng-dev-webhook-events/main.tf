# Configure the GitHub Provider
provider "github" {
  owner = var.github_owner
}

locals {
  lb_account_id                   = "652711504416"
  webhook_secret_key              = "/codepipeline/webhooks/secret"
  vpc_id                          = data.terraform_remote_state.vpc.outputs.vpc_id
  artefacts_bucket                = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket                 = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn                    = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  name                            = "eng-webhook-events"
  github_oauth_token_ssm_param    = "/manually/created/engineering/dev/codepipeline/github/accesstoken"
  webhook_events_payload_file     = "../functions/webhook-events/function.zip"
  webhook_handler_payload_file    = "../functions/webhook-handler/function.zip"
  webhook_dispatcher_payload_file = "../functions/webhook-dispatcher/function.zip"
  webhook_handler_key             = "lambda/webhook_handler/${filemd5(local.webhook_handler_payload_file)}/function.zip"
  webhook_events_key              = "lambda/webhook_emitter/${filemd5(local.webhook_events_payload_file)}/function.zip"
  webhook_dispatcher_key          = "lambda/webhook_dispatcher/${filemd5(local.webhook_dispatcher_payload_file)}/function.zip"
  emitter_function_name           = "${local.name}-emitter"
  handler_function_name           = "${local.name}-handler"
  dispatcher_function_name        = "${local.name}-dispatcher"
  event_bus_name                  = "default"
  event_bus_source_id             = "eng.ci.webhooks"
  dispatcher_bus_source_id        = "eng.ci.dispatcher"
  dns_host                        = "${local.name}.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
  public_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.public-subnet-az3,
  ]
}
