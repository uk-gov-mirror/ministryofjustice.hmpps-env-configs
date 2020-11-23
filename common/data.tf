# codebuild assume
data "template_file" "codebuild_role" {
  template = file("./templates/iam/assume_codebuild.tmpl")
  vars     = {}
}

# codebuild build role
data "template_file" "codebuild_iam_policy" {
  template = file("./templates/iam/build_role.tmpl")
  vars = {
    s3_bucket_arn        = aws_s3_bucket.codepipeline.arn
    artefacts_bucket_arn = aws_s3_bucket.artefacts.arn
    cache_bucket_arn     = aws_s3_bucket.cache.arn
    build_cache_bucket_arn = aws_s3_bucket.temp.arn
  }
}
# codebuild packer builder assume
data "template_file" "codebuild_role_packer_builder" {
  template = file("./templates/iam/assume_codebuild_packer_ami_builder.tmpl")
  vars     = {}
}

# codebuild docker image builder assume
data "template_file" "codebuild_role_docker_image_builder" {
  template = file("./templates/iam/assume_codebuild_docker_image_builder.tmpl")
  vars     = {}
}


# codepipeline packer builder assume
data "template_file" "codepipeline_role_packer_builder" {
  template = file("./templates/iam/assume_codepipeline_packer_ami_builder.tmpl")
  vars     = {}
}

# codepipeline docker image builder assume
data "template_file" "codepipeline_role_docker_image_builder" {
  template = file("./templates/iam/assume_codepipeline_docker_image_builder.tmpl")
  vars     = {}
}


# codebuild packer builder role
data "template_file" "codebuild_iam_policy_packer_builder" {
  template = file("./templates/iam/build_role_packer_ami_builder.tmpl")
  vars = {
    s3_bucket_arn        = aws_s3_bucket.codepipeline.arn
    artefacts_bucket_arn = aws_s3_bucket.artefacts.arn
    cache_bucket_arn     = aws_s3_bucket.cache.arn
  }
}

# codebuild docker image builder role
data "template_file" "codebuild_iam_policy_docker_image_builder" {
  template = file("./templates/iam/build_role_docker_image_builder.tmpl")
  vars = {
    s3_bucket_arn        = aws_s3_bucket.codepipeline.arn
    artefacts_bucket_arn = aws_s3_bucket.artefacts.arn
    cache_bucket_arn     = aws_s3_bucket.cache.arn
  }
}

# codepipeline packer builder role
data "template_file" "codepipeline_iam_policy_packer_builder" {
  template = file("./templates/iam/codepipeline_role_packer_ami_builder.tmpl")
  vars = {
    s3_bucket_arn        = aws_s3_bucket.codepipeline.arn
    artefacts_bucket_arn = aws_s3_bucket.artefacts.arn
    cache_bucket_arn     = aws_s3_bucket.cache.arn
  }
}

# codepipeline docker image role
data "template_file" "codepipeline_iam_policy_docker_image_builder" {
  template = file("./templates/iam/codepipeline_role_docker_image_builder.tmpl")
  vars = {
    s3_bucket_arn        = aws_s3_bucket.codepipeline.arn
    artefacts_bucket_arn = aws_s3_bucket.artefacts.arn
    cache_bucket_arn     = aws_s3_bucket.cache.arn
  }
}

data "template_file" "codepipeline_iam_policy_packer_builder_s3" {
  template = file("./templates/iam/codepipeline_role_packer_ami_builder_s3.tmpl")
  vars = {
    s3_bucket_arn        = aws_s3_bucket.codepipeline.arn
    artefacts_bucket_arn = aws_s3_bucket.artefacts.arn
    cache_bucket_arn     = aws_s3_bucket.cache.arn
  }
}

# codepipeline docker image role s3
data "template_file" "codepipeline_iam_policy_docker_image_builder_s3" {
  template = file("./templates/iam/codepipeline_role_docker_image_builder_s3.tmpl")
  vars = {
    s3_bucket_arn        = aws_s3_bucket.codepipeline.arn
    artefacts_bucket_arn = aws_s3_bucket.artefacts.arn
    cache_bucket_arn     = aws_s3_bucket.cache.arn
  }
}


# kms 
data "template_file" "kms" {
  template = file("../policies/cloudwatch.kms.json")

  vars = {
    region     = local.region
    account_id = local.account_id
  }
}

# account id
data "aws_caller_identity" "current" {
}

# ssm
data "aws_ssm_parameter" "jenkins_token" {
  name = var.code_build["jenkins_token_ssm"]
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}
