# primary origin = Singapore ALB, read from its state file
data "terraform_remote_state" "app_singapore" {
  backend = "local"

  config = {
    path = "../application/terraform.singapore.tfstate"
  }
}

# managed policies: cache hard, but still forward Host/cookies/query to the origin
data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}
