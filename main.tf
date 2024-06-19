terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Create a VPC
module "vpc" {
    source = "./modules/vpc"
    cidr_block = ""
    vpc_tag_name = ""
}