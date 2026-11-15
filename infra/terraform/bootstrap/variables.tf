variable "aws_region" {
  description = "The AWS region where the S3 bucket will be created"
  type        = string
}

variable "bootstrap_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "The environment for the Terraform state"
  type        = string

  validation {
    condition     = contains(["dev", "stag", "prod"], var.environment)
    error_message = "The environment must be either 'dev', 'stag', or 'prod'."
  }
}