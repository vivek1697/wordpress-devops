output "security_group_id" {
  description = "app-tier SG id; Aurora and EFS allow it in"
  value       = aws_security_group.app.id
}

output "asg_name" {
  description = "auto scaling group name"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "launch template id"
  value       = aws_launch_template.this.id
}
