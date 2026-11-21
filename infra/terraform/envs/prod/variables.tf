# All of these are set by CD through TF_VAR_* env vars, which are filled from
# the GitHub environment's Actions variables and secrets (the email addresses).
# Locally, export the same TF_VAR_* values or pass -var on the command line.

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "environment" {
  description = "Environment name, e.g. dev or prod. Used for tagging and resource names."
  type        = string
  default     = "prod"
}

# S3 bucket variables
variable "site_bucket_name" {
  description = "Name of the S3 bucket that hosts the site. Must be globally unique."
  type        = string
}

# Lambda variables. The role ARN and both sender addresses are published by
# bootstrap, so they always match what the role is allowed to do.
variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role created by bootstrap."
  type        = string
}

variable "ses_from_email" {
  description = "SES sender address for contact messages."
  type        = string
}

variable "ses_auto_reply_from_email" {
  description = "SES sender address for auto-replies."
  type        = string
}

variable "contact_recipient_email" {
  description = "Address that receives contact form messages."
  type        = string
  sensitive   = true
}

# SES variables
variable "ses_email_identity" {
  description = "Domain or address to register with SES."
  type        = string
  default     = "jacobsidhu.com"
}

variable "manage_ses_identity" {
  description = "Create the SES identity in this env. Leave false while dev owns it in the same account."
  type        = bool
  default     = false
}

# Domain variables
variable "enable_custom_domain" {
  description = "Create the certificate and custom domain for the API."
  type        = bool
  default     = true
}

variable "portfolio_domain_name" {
  description = "Hostname for the prod site."
  type        = string
  default     = "jacobsidhu.com"
}
