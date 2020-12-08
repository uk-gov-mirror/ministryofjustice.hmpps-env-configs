#-----------------------------------------
# Event
#-----------------------------------------

resource "aws_cloudwatch_event_rule" "nextcloud" {
  name                = "${var.name}-nextcloud-db-bkup-event-rule"
  description         = "Rule for nextcloud db backups"
  schedule_expression = var.schedule_expression
}


resource "aws_cloudwatch_event_target" "nextcloud" {
  arn      = "arn:aws:codepipeline:${var.region}:${var.account_id}:${var.name}-${var.prefix}-db-backup"
  rule     = aws_cloudwatch_event_rule.nextcloud.name
  role_arn = aws_iam_role.nextcloud.arn
}

#-----------------------------------------
# IAM Role
#-----------------------------------------

resource "aws_iam_role" "nextcloud" {
  name               = "${var.name}-nextcloud-db-bkup-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

#-----------------------------------------
# IAM Policy
#-----------------------------------------

resource "aws_iam_policy" "nextcloud" {
  name        = "${var.name}-nextcloud-db-bkup-policy"
  description = "Policy to allow Event rule to invoke Codepipeline"

policy = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
{
      "Effect": "Allow",
      "Action": ["codepipeline:StartPipelineExecution"],
      "Resource": ["arn:aws:codepipeline:${var.region}:${var.account_id}:${var.name}-${var.prefix}-db-backup"]
          }
      ]
  }

POLICY

}

#-----------------------------------------
# IAM Policy Attachment
#-----------------------------------------
resource "aws_iam_role_policy_attachment" "nextcloud" {
  role       = aws_iam_role.nextcloud.name
  policy_arn = aws_iam_policy.nextcloud.arn
}
