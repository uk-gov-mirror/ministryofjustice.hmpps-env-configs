resource "aws_s3_bucket" "temp" {
  bucket = "${local.common_name}-temp"
  acl    = "private"

  versioning {
    enabled = false
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
      days = 1
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    },
  )
}

resource "aws_s3_bucket" "codepipeline" {
  bucket = local.common_name
  acl    = "private"

  versioning {
    enabled = false
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
      "Name" = local.common_name
    },
  )
}

resource "aws_s3_bucket_metric" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.bucket
  name   = "EntireBucket"
}

