output "file_system_id" {
  description = "EFS file system id"
  value       = aws_efs_file_system.this.id
}

output "dns_name" {
  description = "EFS DNS name instances mount"
  value       = aws_efs_file_system.this.dns_name
}

output "security_group_id" {
  description = "EFS security group id"
  value       = aws_security_group.efs.id
}
