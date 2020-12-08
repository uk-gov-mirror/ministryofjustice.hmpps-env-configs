output "pipeline_arn" {
  value = {
    for arn in aws_codepipeline.pipeline:
    arn.name => arn.arn
  }
}
