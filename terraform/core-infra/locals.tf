locals {
  name_prefix = "${var.project}-${var.environment}"

  # applied to every resource via the provider's default_tags
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
