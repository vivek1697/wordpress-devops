variable "project" {
  description = "name prefix for resources and tags"
  type        = string
  default     = "wp-devops"
}

variable "environment" {
  description = "environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# no default on purpose — avoids deploying to the wrong region by accident
variable "aws_region" {
  description = "region to deploy into"
  type        = string
}
