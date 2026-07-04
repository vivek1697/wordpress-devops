variable "name_prefix" {
  description = "Prefix for resource names, e.g. wordpress-devops-dev."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "How many AZs to spread subnets across."
  type        = number
  default     = 2
}
