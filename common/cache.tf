resource "aws_s3_bucket" "cache" {
  bucket = "${local.common_name}-cache"
  acl    = "private"

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

  tags = merge(local.tags, {"Name" = "${local.common_name}-cache"})
}

resource "aws_s3_bucket_metric" "cache" {
  bucket = aws_s3_bucket.cache.bucket
  name   = "EntireBucket"
}
