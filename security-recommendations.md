# Security Recommendations for Terraform-Workflow-AWS

This document outlines security vulnerabilities identified in the current Terraform configuration and provides recommendations for addressing them.

## Current Security Posture

The current implementation has several strong security controls in place:

- ✅ S3 bucket is configured as private with all public access blocked
- ✅ CloudFront Origin Access Control (OAC) is properly implemented
- ✅ S3 bucket policy restricts access to only the CloudFront distribution
- ✅ HTTPS is enforced with redirect-to-https viewer protocol policy
- ✅ Server-side encryption is enabled on the S3 bucket with AES256
- ✅ Versioning is enabled on the S3 bucket

## Identified Vulnerabilities and Recommendations

### 1. Missing Access Logging

**Vulnerability**: The S3 bucket and CloudFront distribution do not have access logging enabled, making it difficult to detect and investigate unauthorized access attempts or security incidents.

**Recommendation**: Enable access logging for both S3 and CloudFront:

```hcl
# S3 Logging Bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.bucket_name}-logs"
  
  # Add appropriate access controls and lifecycle policies
}

# Enable S3 Access Logging
resource "aws_s3_bucket_logging" "website_logging" {
  bucket        = aws_s3_bucket.website_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "s3-access-logs/"
}

# Enable CloudFront Access Logging
resource "aws_cloudfront_distribution" "s3_distribution" {
  # Existing configuration...
  
  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.logging_bucket.bucket_domain_name}"
    prefix          = "cloudfront-logs/"
  }
}
```

### 2. Missing Security Headers

**Vulnerability**: The CloudFront distribution does not add security headers like Content-Security-Policy, X-Content-Type-Options, and X-XSS-Protection.

**Recommendation**: Add a response headers policy to CloudFront:

```hcl
resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "${var.bucket_name}-security-headers"
  
  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'self'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override = true
    }
    
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    
    content_type_options {
      override = true
    }
    
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
  }
}

# Then reference in CloudFront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  # Existing configuration...
  
  default_cache_behavior {
    # Existing configuration...
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id
  }
}
```

### 3. No WAF Protection

**Vulnerability**: The CloudFront distribution is not protected by AWS WAF, making it vulnerable to common web exploits.

**Recommendation**: Add AWS WAF with a basic rule set:

```hcl
resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name        = "${var.bucket_name}-waf"
  description = "WAF for CloudFront distribution"
  scope       = "CLOUDFRONT"
  
  default_action {
    allow {}
  }
  
  # Add AWS managed rule groups
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    
    override_action {
      none {}
    }
    
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.bucket_name}-waf"
    sampled_requests_enabled   = true
  }
}

# Then reference in CloudFront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  # Existing configuration...
  web_acl_id = aws_wafv2_web_acl.cloudfront_waf.arn
}
```

### 4. Lack of Object Lifecycle Policy

**Vulnerability**: No lifecycle policy is defined for S3 objects, which could lead to unnecessary storage costs and potential security risks from retaining outdated content.

**Recommendation**: Add a lifecycle policy:

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "website_lifecycle" {
  bucket = aws_s3_bucket.website_bucket.id
  
  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
```

### 5. GitHub Actions Workflow Security

**Vulnerability**: The GitHub Actions workflow uses a fixed Terraform version and doesn't include security scanning.

**Recommendation**: Update the workflow to include security scanning and use the latest Terraform version:

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: "~>1.6.0"  # Use semantic versioning for latest 1.6.x

- name: Run tfsec
  uses: aquasecurity/tfsec-action@v1.0.0
  with:
    soft_fail: true

- name: Run checkov
  uses: bridgecrewio/checkov-action@master
  with:
    directory: .
    framework: terraform
```

## Implementation Priority

1. **High Priority**:
   - Enable access logging for both S3 and CloudFront
   - Add security headers to CloudFront responses

2. **Medium Priority**:
   - Implement AWS WAF protection
   - Add S3 lifecycle policies

3. **Low Priority**:
   - Update GitHub Actions workflow with security scanning

## Conclusion

While the current implementation has a solid security foundation, implementing these recommendations will significantly enhance the security posture of your static website hosting infrastructure and help protect against common web vulnerabilities and threats.