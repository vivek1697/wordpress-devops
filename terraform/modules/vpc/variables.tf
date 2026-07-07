variable "name_prefix" {
  description = "name prefix for resources"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "how many AZs to spread subnets across"
  type        = number
  default     = 2
}
