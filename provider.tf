terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      version = "~> 4.12.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}