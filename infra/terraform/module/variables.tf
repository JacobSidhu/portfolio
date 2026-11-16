variable "aws_region" {
  description = "The AWS region where the S3 bucket will be created"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "The environment for the S3 bucket (e.g., dev, prod)"
  type        = string
  default     = "dev"
}