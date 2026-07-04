locals {
  name_prefix = "${var.project}-${var.environment}"

  # Applied to every resource through the provider's default_tags.
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
