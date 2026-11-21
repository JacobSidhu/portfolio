terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Left empty on purpose. Bucket, key and region are passed with
  # -backend-config at init time (see the CD workflow), so the same code
  # works for any environment without hardcoding state locations.
  backend "s3" {}
}

# Credentials come from the role CD assumes through GitHub OIDC,
# or from AWS_PROFILE when running locally.
provider "aws" {
  region = var.aws_region
}
