terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # local state for the demo. prod: S3 + DynamoDB lock (below)
  #
  # backend "s3" {
  #   bucket         = "wordpress-devops-tfstate"
  #   key            = "application/terraform.tfstate"
  #   region         = "ap-southeast-1"
  #   dynamodb_table = "wordpress-devops-tflock"
  #   encrypt        = true
  # }
}
