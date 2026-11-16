# All of these are set by CD through TF_VAR_* env vars, which are filled from
# the GitHub environment's Actions variables. Locally, export the same
# TF_VAR_* values or pass -var on the command line.

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "environment" {
  description = "Environment name, e.g. dev or prod. Used for tagging."
  type        = string
  default     = "dev"
}

# S3 bucket variables
variable "site_bucket_name" {
  description = "Name of the S3 bucket that hosts the site. Must be globally unique."
  type        = string
}
