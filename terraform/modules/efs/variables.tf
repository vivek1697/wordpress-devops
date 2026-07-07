variable "name_prefix" {
  description = "name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC for the mount-target security group"
  type        = string
}

variable "subnet_ids" {
  description = "app-tier subnets, one mount target in each"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "app-tier SGs allowed to mount EFS over NFS (2049)"
  type        = list(string)
  default     = []
}
