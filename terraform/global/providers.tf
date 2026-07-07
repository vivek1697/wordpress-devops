# CloudFront-scoped WAF must live in us-east-1, so the whole stack runs there
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
