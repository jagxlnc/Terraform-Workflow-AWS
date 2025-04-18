provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "mcp-demo-1804"

  tags = {
    Name        = "MCP-Demo-1804"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "private_bucket_access" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versioning configuration
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.private_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}