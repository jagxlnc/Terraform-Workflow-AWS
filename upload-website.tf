# Upload index.html to S3
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "${path.module}/sample-website/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/sample-website/index.html")

  depends_on = [aws_s3_bucket.website_bucket]
}

# Upload error.html to S3
resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "error.html"
  source       = "${path.module}/sample-website/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/sample-website/error.html")

  depends_on = [aws_s3_bucket.website_bucket]
}