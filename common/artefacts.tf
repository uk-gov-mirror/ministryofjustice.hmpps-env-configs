data "aws_iam_policy_document" "artefacts" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = concat(
        values(local.hmpps_account_ids)
      )
    }
    actions = ["s3:Get*", "s3:List*"]
    resources = [
      aws_s3_bucket.artefacts.arn,
      "${aws_s3_bucket.artefacts.arn}/lambda/eng-lambda-functions-builder/latest/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "artefacts" {
  bucket = aws_s3_bucket.artefacts.id
  policy = data.aws_iam_policy_document.artefacts.json
}
resource "aws_s3_bucket" "artefacts" {
  bucket = "${local.common_name}-artefact"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    enabled = true
    expiration {
      days = var.code_build["artifact_expiration"]
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-artefact"
    },
  )
}

resource "aws_s3_bucket_metric" "artefacts" {
  bucket = aws_s3_bucket.artefacts.bucket
  name   = "EntireBucket"
}

