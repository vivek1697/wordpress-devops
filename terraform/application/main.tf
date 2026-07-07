# read core-infra's VPC/subnets from that region's state file
data "terraform_remote_state" "core" {
  backend = "local"

  config = {
    path = "../core-infra/terraform.${local.region_code}.tfstate"
  }
}

# the DB secret lives only in the primary. secondaries read its ARN from the
# primary's state and fetch it cross-region at boot
data "terraform_remote_state" "primary_app" {
  count   = local.is_primary ? 0 : 1
  backend = "local"

  config = {
    path = "terraform.${local.primary_region_code}.tfstate"
  }
}

locals {
  vpc_id                  = data.terraform_remote_state.core.outputs.vpc_id
  public_subnet_ids       = data.terraform_remote_state.core.outputs.public_subnet_ids
  private_app_subnet_ids  = data.terraform_remote_state.core.outputs.private_app_subnet_ids
  private_data_subnet_ids = data.terraform_remote_state.core.outputs.private_data_subnet_ids

  # primary uses its own secret; secondary uses the primary's ARN
  db_secret_arn = local.is_primary ? module.aurora.db_secret_arn : data.terraform_remote_state.primary_app[0].outputs.db_secret_arn
}

module "alb" {
  source = "../modules/alb"

  name_prefix       = local.name_prefix
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnet_ids
}

module "efs" {
  source = "../modules/efs"

  name_prefix = local.name_prefix
  vpc_id      = local.vpc_id
  subnet_ids  = local.private_app_subnet_ids

  # only the app tier may mount it
  allowed_security_group_ids = [module.asg.security_group_id]
}

module "aurora" {
  source = "../modules/aurora"

  name_prefix = local.name_prefix
  vpc_id      = local.vpc_id
  subnet_ids  = local.private_data_subnet_ids

  # only the app tier may reach the DB
  allowed_security_group_ids = [module.asg.security_group_id]

  is_primary                = local.is_primary
  global_cluster_identifier = local.global_cluster_identifier
}

module "asg" {
  source = "../modules/asg"

  name_prefix           = local.name_prefix
  vpc_id                = local.vpc_id
  private_subnet_ids    = local.private_app_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arns     = [module.alb.target_group_arn]

  ami_id        = var.ami_id
  db_host       = module.aurora.cluster_endpoint
  db_secret_arn = local.db_secret_arn
  efs_dns_name  = module.efs.dns_name
}
