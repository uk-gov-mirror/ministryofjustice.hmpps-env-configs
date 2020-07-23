resource "aws_iam_role" "codebuild" {
  name               = local.common_name
  assume_role_policy = data.template_file.codebuild_role.rendered
  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    },
  )
}

# resource "aws_iam_role_policy" "codebuild" {
#   role   = "${aws_iam_role.codebuild.name}"
#   policy = "${data.template_file.codebuild_iam_policy.rendered}"
# }

resource "aws_iam_policy" "codebuild_policy" {
  name        = local.common_name
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"
  policy      = data.template_file.codebuild_iam_policy.rendered
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = aws_iam_policy.codebuild_policy.arn
  roles      = [aws_iam_role.codebuild.id]
}

#============================================
# Packer AMI CodeBuildå Role & Policies
#============================================
resource "aws_iam_role" "codebuild_packer_ami_builder" {
  name               = "hmpps-eng-builds-packer-ami-builder"
  assume_role_policy = data.template_file.codebuild_role_packer_builder.rendered
  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    },
  )
}

resource "aws_iam_policy" "codebuild_packer_ami_builder_policy" {
  name        = "codebuild-policy-packer-ami-builder"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild for Packer AMI Builder"
  policy      = data.template_file.codebuild_iam_policy_packer_builder.rendered
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment_packer_ami_builder" {
  name       = "codebuild-policy-attachment-packer-ami-builder"
  policy_arn = aws_iam_policy.codebuild_packer_ami_builder_policy.arn
  roles      = [aws_iam_role.codebuild_packer_ami_builder.id]
}


#============================================
# Packer CodePipeline Builder Role & Policies
#============================================
resource "aws_iam_role" "codepipeline_packer_ami_builder" {
  name               = "hmpps-eng-builds-packer-ami-builder-codepipeline"
  assume_role_policy = data.template_file.codebuild_role_packer_builder.rendered
  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    },
  )
}

resource "aws_iam_policy" "codepipeline_packer_ami_builder_policy" {
  name        = "codepipeline-policy-packer-ami-builder"
  path        = "/service-role/"
  description = "Policy used for CodePipeline for Packer AMI Builder"
  policy      = data.template_file.codepipeline_iam_policy_packer_builder.rendered
}

resource "aws_iam_policy_attachment" "codepipeline_policy_attachment_packer_ami_builder" {
  name       = "codepipeline-policy-attachment-packer-ami-builder"
  policy_arn = aws_iam_policy.codepipeline_packer_ami_builder_policy.arn
  roles      = [aws_iam_role.codepipeline_packer_ami_builder.id]
}

resource "aws_iam_policy" "codepipeline_packer_ami_builder_policy_s3" {
  name        = "codepipeline-policy-packer-ami-builder-s3"
  path        = "/service-role/"
  description = "Policy used for CodePipeline for Packer AMI Builder"
  policy      = data.template_file.codepipeline_iam_policy_packer_builder_s3.rendered
}

resource "aws_iam_policy_attachment" "codepipeline_policy_attachment_packer_ami_builder_s3" {
  name       = "codepipeline-policy-attachment-packer-ami-builder-s3"
  policy_arn = aws_iam_policy.codepipeline_packer_ami_builder_policy_s3.arn
  roles      = [aws_iam_role.codepipeline_packer_ami_builder.id]
}
