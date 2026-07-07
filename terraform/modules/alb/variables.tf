variable "name_prefix" {
  description = "name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC for the ALB and target group"
  type        = string
}

variable "public_subnet_ids" {
  description = "public subnets to place the ALB in"
  type        = list(string)
}

variable "ingress_cidr_blocks" {
  description = "CIDRs allowed on port 80 (prod: lock to CloudFront's prefix list)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "health_check_path" {
  description = "path the ALB pings for target health"
  type        = string
  default     = "/"
}
