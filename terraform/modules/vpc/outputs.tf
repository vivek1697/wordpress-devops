output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "public subnet ids"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "app-tier private subnet ids (WordPress, EFS)"
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  description = "data-tier private subnet ids (Aurora)"
  value       = aws_subnet.private_data[*].id
}
