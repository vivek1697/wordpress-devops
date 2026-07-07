resource "aws_cloudfront_distribution" "this" {
  enabled = true
  comment = "${local.name_prefix} WordPress edge"

  # single origin = Singapore ALB. CloudFront terminates HTTPS, talks HTTP to it.
  # origin groups only fail over GET/HEAD (no POST), so failover is a Route53 job;
  # Ireland stays a warm standby.
  origin {
    origin_id   = local.primary_origin_id
    domain_name = local.primary_origin_domain

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.primary_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  # geo restriction is done in WAF, more flexible than this block
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # no domain, so use the free *.cloudfront.net cert
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id  = aws_wafv2_web_acl.this.arn
  price_class = "PriceClass_All"
}
