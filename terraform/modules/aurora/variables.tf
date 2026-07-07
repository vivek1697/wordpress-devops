variable "name_prefix" {
  description = "name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC for the DB security group"
  type        = string
}

variable "subnet_ids" {
  description = "private subnets for the DB subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "app-tier SGs allowed to reach the DB on 3306"
  type        = list(string)
  default     = []
}

variable "database_name" {
  description = "initial database WordPress connects to"
  type        = string
  default     = "wordpress"
}

variable "master_username" {
  description = "Aurora master username"
  type        = string
  default     = "wpadmin"
}

variable "is_primary" {
  description = "true for the writer region, false for a reader"
  type        = bool
  default     = true
}

variable "global_cluster_identifier" {
  description = "global cluster name; primary creates it, secondary joins by name"
  type        = string
}

variable "instance_class" {
  description = "Aurora instance size"
  type        = string
  default     = "db.r6g.large"
}

variable "instance_count" {
  description = "cluster instances (1 for demo, 2+ for HA)"
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "Aurora MySQL version (must support global databases)"
  type        = string
  default     = "8.0.mysql_aurora.3.12.0"
}
