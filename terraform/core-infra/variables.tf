variable "project" {
  description = "Project name, used as a prefix for names and tags."
  type        = string
  default     = "wp-devops"
}

variable "environment" {
  description = "Environment name, e.g. demo, staging, prod."
  type        = string
  default     = "dev"
}

# No default on purpose, so we never deploy to the wrong region by accident.
variable "aws_region" {
  description = "Region to deploy this stack into."
  type        = string
}
