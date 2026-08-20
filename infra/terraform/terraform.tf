terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket = "jacobsidhu"
    key    = "portfolio/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.60.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
