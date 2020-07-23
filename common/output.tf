output "codebuild_info" {
  value = {
    log_group                             = module.create_loggroup.loggroup_name
    iam_role_arn                          = aws_iam_role.codebuild.arn
    artefacts_bucket                      = aws_s3_bucket.artefacts.bucket
    cache_bucket                          = aws_s3_bucket.cache.bucket
    pipeline_bucket                       = aws_s3_bucket.codepipeline.bucket
    iam_role_arn_packer_ami_builder       = aws_iam_role.codebuild_packer_ami_builder.arn
    packerbuilder_instance_security_group = aws_security_group.packerbuilder_instance_security_group.id
    packerbuilder_client_security_group   = aws_security_group.packerbuilder_client_security_group.id
  }
}

output "packerbuilder_info" {
  value = {
    log_group                 = module.create_loggroup_packer_ami_builder.loggroup_name
    iam_role_arn              = aws_iam_role.codebuild_packer_ami_builder.arn
    iam_role_arn_codepipeline = aws_iam_role.codepipeline_packer_ami_builder.arn
    artefacts_bucket          = aws_s3_bucket.artefacts.bucket
    instance_security_group   = aws_security_group.packerbuilder_instance_security_group.id
    client_security_group     = aws_security_group.packerbuilder_client_security_group.id
  }
}

output "projects" {
  value = {
    ansible = aws_codebuild_project.ansible3.name
    python3 = aws_codebuild_project.python3.name
  }
}
