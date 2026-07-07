output "alb_dns_name" {
  description = "public ALB hostname for this region"
  value       = module.alb.alb_dns_name
}

output "aurora_writer_endpoint" {
  description = "Aurora writer endpoint"
  value       = module.aurora.cluster_endpoint
}

# primary publishes the secret ARN so secondaries (which have none) can read it
output "db_secret_arn" {
  description = "DB password secret ARN for this region"
  value       = local.db_secret_arn
}
