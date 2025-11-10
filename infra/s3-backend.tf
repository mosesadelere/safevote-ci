resource "aws_s3_bucket" "build_artifacts" {
  bucket = "safevote-builds-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
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
    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name        = "safevote-builds-${var.environment}"
    Environment = var.environment
  }
}

# Bucket policy to allow GitHub Actions to upload artifacts
resource "aws_iam_policy" "github_actions_upload" {
  name        = "safevote-github-actions-upload-${var.environment}"
  description = "Allows GitHub Actions to upload build artifacts"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.build_artifacts.arn,
          "${aws_s3_bucket.build_artifacts.arn}/*"
        ]
      }
    ]
  })
}

# Output the bucket name for use in GitHub Actions
output "build_artifacts_bucket_name" {
  value = aws_s3_bucket.build_artifacts.bucket
}
