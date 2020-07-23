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

