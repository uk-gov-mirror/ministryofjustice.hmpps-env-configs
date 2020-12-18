data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "packer_policy_document" {
  statement {
    effect    = "Allow"
    sid       = "EC2Perms"
    resources = ["*"]
    actions = [
      "ec2:DetachVolume",
      "ec2:CreateVolume",
      "ec2:AttachVolume",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumeStatus",
      "sts:DecodeAuthorizationMessage",
      "ec2:DescribeVolumes",
      "ec2:DescribeInstances",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
  }
  statement {
    sid    = "S3Perms"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::tf-eu-west-2-hmpps-eng-dev-config-s3bucket",
      "arn:aws:s3:::tf-eu-west-2-hmpps-eng-dev-config-s3bucket/*",
      "arn:aws:s3:::hmpps-eng-dev-alfresco-rpms",
      "arn:aws:s3:::hmpps-eng-dev-alfresco-rpms/*"
    ]
  }
}

resource "aws_iam_policy" "packer" {
  name   = "${local.packer_build_role}-policy"
  policy = data.aws_iam_policy_document.packer_policy_document.json
}

resource "aws_iam_role" "packer" {
  name               = local.packer_build_role
  description        = "Role for ${local.packer_build_role}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  tags               = merge(local.tags, { Name = local.packer_build_role })
}

resource "aws_iam_role_policy_attachment" "packer" {
  policy_arn = aws_iam_policy.packer.arn
  role       = aws_iam_role.packer.name
}

resource "aws_iam_instance_profile" "test_profile" {
  name = local.packer_build_role
  role = aws_iam_role.packer.name
}
