resource "aws_iam_role" "oracle_codebuild_iam_role" {
  name               = "oracle-codebuild-role"
  assume_role_policy = data.template_file.oracle_codebuild_role.rendered
  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    },
  )
}

resource "aws_iam_policy" "oracle_codebuild_iam_policy" {
  name        = "oracle-codebuild-policy"
  path        = "/service-role/"
  description = "Policy for using Codebuild for Oracle based projects"
  policy      = data.template_file.oracle_codebuild_iam_policy.rendered
}

resource "aws_iam_policy_attachment" "oracle_codebuild_iam_policy_attachementr" {
  name       = "oracle-codebuild-policy-attachment"
  policy_arn = aws_iam_policy.oracle_codebuild_iam_policy.arn
  roles      = [aws_iam_role.oracle_codebuild_iam_role.id]
}
