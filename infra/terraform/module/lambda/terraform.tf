# archive_file comes from hashicorp/archive, which the environments don't
# declare themselves, so pin it here.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}
