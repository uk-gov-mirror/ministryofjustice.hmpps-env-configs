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
    terraform_plan   = "${local.common_name}-terraform-plan"
    terraform_apply   = "${local.common_name}-terraform-apply"
    terraform_package = "${local.common_name}-terraform-package"
    python3           = aws_codebuild_project.python3.id
    ansible3          = aws_codebuild_project.ansible3.id
    ansible2          = aws_codebuild_project.ansible2.id
    ansible           = "${local.common_name}-terraform-ansible"
  }
}
