module "vpc" {
  source = "../modules/vpc"

  name_prefix = local.name_prefix
  # vpc_cidr and az_count use module defaults (10.0.0.0/16, 2 AZs)
}
