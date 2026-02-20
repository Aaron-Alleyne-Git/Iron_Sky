# This module creates the primary S3 bucket for replication in the AWS Iron Sky Foundation.

resource "aws_s3_bucket" "primary" {
  bucket = "cloudguard-dr-primary-${var.environment}"

  tags = {
    Name        = "CloudGuard DR Primary"
    Environment = var.environment
    Replication = "source"
  }
}

resource "aws_s3_bucket_versioning" "primary" {
  bucket = aws_s3_bucket.primary.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "primary_bucket_id" {
  value = aws_s3_bucket.primary.id
}

output "primary_bucket_arn" {
  value = aws_s3_bucket.primary.arn
}