packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

# Regions to copy the finished AMI into, so every region runs identical bits.
variable "copy_regions" {
  type    = list(string)
  default = ["eu-west-1"]
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

# Latest Ubuntu 22.04 LTS from Canonical, used as the base to build on.
data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"] # Canonical
  region      = var.region
}

locals {
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
}

source "amazon-ebs" "wordpress" {
  region        = var.region
  ami_regions   = concat([var.region], var.copy_regions)
  instance_type = var.instance_type
  source_ami    = data.amazon-ami.ubuntu.id
  ssh_username  = "ubuntu"
  ami_name      = "wp-devops-${local.timestamp}"

  tags = {
    Project   = "wp-devops"
    ManagedBy = "packer"
    OS        = "ubuntu-22.04"
  }
}

build {
  sources = ["source.amazon-ebs.wordpress"]

  # Run the same playbook that would configure any WordPress host.
  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }

  # Write the new AMI id to manifest.json so the pipeline can read it.
  post-processor "manifest" {
    output = "manifest.json"
  }
}
