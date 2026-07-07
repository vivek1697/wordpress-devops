variable "project" {
  description = "name prefix for resources and tags"
  type        = string
  default     = "wp-devops"
}

variable "environment" {
  description = "environment name (dev, staging, QA, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "region to deploy into"
  type        = string
}

variable "ami_id" {
  description = "baked WordPress AMI id"
  type        = string
}
