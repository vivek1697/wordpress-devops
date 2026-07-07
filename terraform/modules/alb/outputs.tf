output "alb_arn" {
  description = "load balancer ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "public ALB DNS name (usable directly, before CloudFront)"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "target group the ASG registers into"
  value       = aws_lb_target_group.this.arn
}

output "security_group_id" {
  description = "ALB SG id; the app tier allows HTTP from it"
  value       = aws_security_group.alb.id
}
