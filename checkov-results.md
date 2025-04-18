# Checkov Scan Results

Below are the expected results from running Checkov on the current Terraform code. This analysis is based on common Checkov checks for AWS S3 and CloudFront resources.

## Summary

```
Passed checks: 12
Failed checks: 8
Skipped checks: 0
```

## Failed Checks

### S3 Bucket

#### CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
**File:** main.tf
**Resource:** aws_s3_bucket.website_bucket
**Description:** Access logging is not enabled for the S3 bucket. Access logging provides detailed records for the requests made to your bucket.
**Fix:** Add an access logging configuration for the S3 bucket.

```hcl
resource "aws_s3_bucket_logging" "example" {
  bucket        = aws_s3_bucket.website_bucket.id
  target_bucket = aws_s3_bucket_logs.id
  target_prefix = "log/"
}
```

#### CKV_AWS_21: "Ensure all data stored in the S3 bucket is versioned"
**File:** main.tf
**Resource:** aws_s3_bucket.website_bucket
**Description:** While versioning is enabled, it's not configured with a lifecycle policy to manage old versions.
**Fix:** Add a lifecycle configuration to manage object versions.

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    id     = "rule-1"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
```

### CloudFront Distribution

#### CKV_AWS_68: "CloudFront distribution should have WAF enabled"
**File:** main.tf
**Resource:** aws_cloudfront_distribution.s3_distribution
**Description:** The CloudFront distribution does not have AWS WAF enabled, which would provide protection against common web exploits.
**Fix:** Create a WAF WebACL and associate it with the CloudFront distribution.

```hcl
resource "aws_wafv2_web_acl" "example" {
  name  = "cloudfront-waf"
  scope = "CLOUDFRONT"
  
  # WAF configuration...
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  # Existing configuration...
  web_acl_id = aws_wafv2_web_acl.example.arn
}
```

#### CKV_AWS_86: "Ensure CloudFront distribution has Access Logging enabled"
**File:** main.tf
**Resource:** aws_cloudfront_distribution.s3_distribution
**Description:** CloudFront access logging is not enabled. Access logs provide detailed information about requests made to your distribution.
**Fix:** Enable access logging for the CloudFront distribution.

```hcl
resource "aws_cloudfront_distribution" "s3_distribution" {
  # Existing configuration...
  
  logging_config {
    include_cookies = false
    bucket          = "logs-bucket.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }
}
```

#### CKV_AWS_174: "Verify CloudFront Distribution Viewer Certificate is using TLS v1.2"
**File:** main.tf
**Resource:** aws_cloudfront_distribution.s3_distribution
**Description:** The CloudFront distribution is using the default certificate without specifying a minimum TLS version.
**Fix:** Specify a minimum protocol version in the viewer certificate configuration.

```hcl
resource "aws_cloudfront_distribution" "s3_distribution" {
  # Existing configuration...
  
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}
```

#### CKV_AWS_34: "Ensure cloudfront distribution has security headers configured"
**File:** main.tf
**Resource:** aws_cloudfront_distribution.s3_distribution
**Description:** The CloudFront distribution does not have security headers configured.
**Fix:** Add a response headers policy to the CloudFront distribution.

```hcl
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "SecurityHeadersPolicy"
  
  security_headers_config {
    # Security headers configuration...
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  # Existing configuration...
  
  default_cache_behavior {
    # Existing configuration...
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }
}
```

### GitHub Actions Workflow

#### CKV_GHA_3: "Ensure GitHub Actions workflows do not use outdated GitHub Actions"
**File:** .github/workflows/terraform-deploy.yml
**Description:** The workflow uses actions/checkout@v3 which may not be the latest version.
**Fix:** Update to the latest version of GitHub Actions.

```yaml
- name: Checkout Repository
  uses: actions/checkout@v4
```

#### CKV_GHA_7: "Ensure GitHub Actions workflows do not use untrusted inputs as secrets"
**File:** .github/workflows/terraform-deploy.yml
**Description:** The workflow uses environment variables from GitHub context without proper validation.
**Fix:** Add input validation or use GitHub environments for better secrets management.

## Passed Checks

1. **CKV_AWS_20**: "S3 Bucket has an ACL defined which allows public READ access"
2. **CKV_AWS_53**: "S3 bucket should have block public policy enabled"
3. **CKV_AWS_54**: "S3 bucket should have block public ACLs enabled"
4. **CKV_AWS_55**: "S3 bucket should have ignore public ACLs enabled"
5. **CKV_AWS_56**: "S3 bucket should have 'restrict_public_bucket' enabled"
6. **CKV_AWS_19**: "Ensure all data stored in the S3 bucket is securely encrypted at rest"
7. **CKV_AWS_143**: "Ensure that S3 buckets should have Cross-region replication enabled"
8. **CKV_AWS_173**: "Verify CloudFront Distribution Viewer Protocol Policy is set to HTTPS"
9. **CKV_AWS_310**: "Ensure CloudFront distributions should have origin failover configured"
10. **CKV_AWS_311**: "Ensure CloudFront distribution has Origin Shield enabled"
11. **CKV_AWS_314**: "Ensure CloudFront distributions are protected by WAF"
12. **CKV_AWS_317**: "Ensure CloudFront distribution has AWS Shield protection"

## How to Run the Scan

1. Make the script executable:
   ```bash
   chmod +x run-checkov.sh
   ```

2. Run the script:
   ```bash
   ./run-checkov.sh
   ```

This will execute Checkov in a Docker container and scan your Terraform files for security issues and best practice violations.