terraform {
    required_version = ">= 1.0.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

// S3 Bucket Module
module "s3" {
    source = "../../module"
    bucket_name = var.bucket_name
    environment = var.environment
}