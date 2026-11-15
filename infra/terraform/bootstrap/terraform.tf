terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.23.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}


provider "github" {
  owner = var.github_owner
}