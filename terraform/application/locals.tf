locals {
  # IAM names are global per account, so the region name avoids collisions
  region_codes = {
    "ap-southeast-1" = "singapore"
    "eu-west-1"      = "ireland"
  }
  region_code = lookup(local.region_codes, var.aws_region, var.aws_region)

  name_prefix = "${var.project}-${var.environment}-${local.region_code}"

  # Singapore is the Aurora Global writer; others join as readers
  primary_region            = "ap-southeast-1"
  primary_region_code       = lookup(local.region_codes, local.primary_region, local.primary_region)
  is_primary                = var.aws_region == local.primary_region
  global_cluster_identifier = "${var.project}-${var.environment}-global"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
