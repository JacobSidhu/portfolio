variable "aws_region" {
  description = "AWS region where the portfolio infrastructure is deployed."
  type        = string
  default     = "eu-west-2"
}

variable "portfolio_bucket_name" {
  description = "Regionaly unique S3 bucket name for the portfolio static website."
  type        = string
}

variable "terraform-state-bucket-name" {
  description = "Globally unique S3 bucket name for storing the Terraform state"
  type        = string
  default     = "terraform-state-bucket-name"
}
