output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.website_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.website_bucket.arn
}

output "bucket_website_endpoint" {
  description = "The website endpoint of the bucket"
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.arn
}