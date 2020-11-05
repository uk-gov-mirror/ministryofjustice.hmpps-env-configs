locals {
  artefacts_bucket             = data.terraform_remote_state.common.outputs.codebuild_info["artefacts_bucket"]
  pipeline_bucket              = data.terraform_remote_state.common.outputs.codebuild_info["pipeline_bucket"]
  iam_role_arn                 = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn"]
  name                         = "eng-webhook-events"
  github_oauth_token_ssm_param = "/manually/created/engineering/dev/codepipeline/github/accesstoken"
  #artifact_bucket_kms_key      = "arn:aws:kms:eu-west-2:895523100917:alias/aws/s3"
}
