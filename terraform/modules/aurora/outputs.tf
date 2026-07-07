output "cluster_endpoint" {
  description = "writer endpoint (WordPress DB_HOST)"
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "reader endpoint"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "database_name" {
  description = "database name"
  value       = aws_rds_cluster.this.database_name
}

output "security_group_id" {
  description = "DB security group id"
  value       = aws_security_group.db.id
}

output "db_secret_arn" {
  description = "DB password secret ARN (primary region only)"
  value       = var.is_primary ? aws_secretsmanager_secret.db[0].arn : null
}
