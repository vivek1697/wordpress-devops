locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  primary_origin_domain = data.terraform_remote_state.app_singapore.outputs.alb_dns_name
  primary_origin_id     = "primary"
}
