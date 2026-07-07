variable "project" {
  description = "name prefix for resources and tags"
  type        = string
  default     = "wp-devops"
}

variable "environment" {
  description = "environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "blocked_country_codes" {
  description = "country codes to block at the edge (e.g. [\"CN\"]); empty = allow all"
  type        = list(string)
  default     = []
}

variable "secondary_origin_domain" {
  description = "Ireland ALB DNS; reserved for Route53 failover, unused by the single-origin CloudFront"
  type        = string
  default     = ""
}
