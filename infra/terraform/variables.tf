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

variable "enable_custom_domain" {
  description = "Whether to create an ACM certificate for the portfolio domain."
  type        = bool
  default     = true
}

variable "portfolio_domain_name" {
  description = "The domain name for the portfolio website."
  type        = string
  default     = "www.jacobsidhu.com"
}

variable "ses_from_email" {
  description = "Verified SES sender address."
  type        = string
  default     = "portfolio@jacobsidhu.com"
}

variable "contact_recipient_email" {
  description = "Email address that receives portfolio contact messages."
  type        = string
  sensitive   = true
}
