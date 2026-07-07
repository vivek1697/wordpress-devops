variable "name_prefix" {
  description = "name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC for the instances"
  type        = string
}

variable "private_subnet_ids" {
  description = "private subnets for the instances"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB SG; instances accept HTTP only from it"
  type        = string
}

variable "target_group_arns" {
  description = "ALB target groups to register instances into"
  type        = list(string)
}

variable "ami_id" {
  description = "baked WordPress AMI id"
  type        = string
}

variable "instance_type" {
  description = "instance size (scale out, not up)"
  type        = string
  default     = "t3.small"
}

variable "min_size" {
  description = "min instances (2 = one per AZ)"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "max instances (tune with load testing)"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "starting instance count; scaling policy owns it after"
  type        = number
  default     = 2
}

variable "cpu_target" {
  description = "target average CPU %"
  type        = number
  default     = 50
}

variable "db_host" {
  description = "Aurora writer endpoint"
  type        = string
}

variable "db_name" {
  description = "WordPress database name"
  type        = string
  default     = "wordpress"
}

variable "db_user" {
  description = "WordPress database user"
  type        = string
  default     = "wpadmin"
}

variable "db_secret_arn" {
  description = "DB password secret ARN; instances read it at boot"
  type        = string
}

variable "efs_dns_name" {
  description = "EFS DNS name, mounted at wp-content/uploads"
  type        = string
}
