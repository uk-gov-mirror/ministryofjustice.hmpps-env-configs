output "codebuild_info" {
  value = {
    log_group                             = module.create_loggroup.loggroup_name
    iam_role_arn                          = aws_iam_role.codebuild.arn
    artefacts_bucket                      = aws_s3_bucket.artefacts.bucket
    cache_bucket                          = aws_s3_bucket.cache.bucket
    build_cache_bucket                    = aws_s3_bucket.temp.bucket
    pipeline_bucket                       = aws_s3_bucket.codepipeline.bucket
    iam_role_arn_packer_ami_builder       = aws_iam_role.codebuild_packer_ami_builder.arn
    iam_role_arn_docker_image_builder     = aws_iam_role.codebuild_docker_image_builder.arn
    packerbuilder_instance_security_group = aws_security_group.packerbuilder_instance_security_group.id
    packerbuilder_client_security_group   = aws_security_group.packerbuilder_client_security_group.id
    packerbuilder_image                   = local.images["packer"]
    packerbuilder_image_latest            = local.images["packer_latest"]
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

output "dockerimagebuilder_info" {
  value = {
    log_group                 = module.create_loggroup_docker_images_builder.loggroup_name
    iam_role_arn              = aws_iam_role.codebuild_docker_image_builder.arn
    iam_role_arn_codepipeline = aws_iam_role.codepipeline_docker_image_builder.arn
    artefacts_bucket          = aws_s3_bucket.artefacts.bucket
    instance_security_group   = aws_security_group.dockerimagebuilder_instance_security_group.id
    client_security_group     = aws_security_group.dockerimagebuilder_client_security_group.id
  }
}

output "tags" {
  value = local.tags
}

output "codebuild_projects" {
  value = {
    terraform_plan           = module.terraform_plan.project_name
    terraform_version        = module.terraform_version.project_name
    terraform_version_ssm    = module.terraform_version_ssm.project_name
    terraform_apply          = module.terraform_apply.project_name
    terraform_package        = module.terraform_package.project_name
    terraform_package_no_tag = module.terraform_package_no_tagging.project_name
    terraform_package_ssm    = module.terraform_package_ssm.project_name
    github_tagger            = module.github_tagger.project_name
    ansible                  = module.ansible_utils.project_name
    python3                  = aws_codebuild_project.python3.id
    ansible3                 = aws_codebuild_project.ansible3.id
    ansible2                 = aws_codebuild_project.ansible2.id
  }
}

output "hmpps_account_ids" {
  value = local.hmpps_account_ids
}
