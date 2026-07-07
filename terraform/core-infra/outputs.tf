output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "public subnet ids"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "app-tier private subnet ids (WordPress, EFS)"
  value       = module.vpc.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "data-tier private subnet ids (Aurora)"
  value       = module.vpc.private_data_subnet_ids
}
