resource "aws_codepipeline" "pipeline" {
  name     = "ten10-serenity-delius-test"
  role_arn = local.iam_role_arn
  tags     = var.tags

  artifact_store {
    type     = "S3"
    location = local.pipeline_bucket
  }

  stage {
    name = "Source"
    action {
      name             = "code"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]
      configuration = {
        Owner                = "ministryofjustice"
        Repo                 = "ndelius-serenity-automation"
        Branch               = "ALS-578"
        PollForSourceChanges = false
      }
    }
  }
  stage {
    name = "Run-Test"
    action {
      name            = "Common"
      input_artifacts = ["code"]
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      configuration = {
        ProjectName   = aws_codebuild_project.task_handler.id
        PrimarySource = "code"
        EnvironmentVariables = jsonencode(
          [
            { "name" : "ARTEFACTS_BUCKET", "value" : "maven-s3-releases-repo", "type" : "PLAINTEXT" },
            { "name" : "TASK_NAME", "value" : "test", "type" : "PLAINTEXT" },
            { "name" : "COMPOSE_FILE_NAME", "value" : "docker-compose.yml", "type" : "PLAINTEXT" },
            { "name" : "TEST_DOCKER_IMAGE", "value" : "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ten10-serenity-tests", "type" : "PLAINTEXT" }
          ]
        )
      }
    }
  }
}
