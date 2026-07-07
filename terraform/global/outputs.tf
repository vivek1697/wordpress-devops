output "cloudfront_domain_name" {
  description = "site URL (e.g. dxxxx.cloudfront.net)"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "web_acl_arn" {
  description = "WAF web ACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}
