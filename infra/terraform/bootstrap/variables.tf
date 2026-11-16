variable "aws_region" {
  description = "The AWS region where the S3 bucket will be created"
  type        = string
}

variable "terraform_role_name" {
  description = "The name of the Terraform role"
  type        = string
}

variable "lambda_role_name" {
  description = "The name of the Lambda role"
  type        = string
}

variable "terraform_policy_name" {
  description = "Full name of the Terraform deployment IAM policy."
  type        = string
}

variable "lambda_policy_name" {
  description = "Full name of the Lambda SES sending IAM policy."
  type        = string
}

variable "site_bucket_name" {
  description = "Full name of the website hosting bucket."
  type        = string
}

variable "site_state_key" {
  description = "S3 object key for the main infrastructure Terraform state."
  type        = string
}

variable "bootstrap_state_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "site_state_bucket_name" {
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
variable "github_owner" {
  description = "The name of the GitHub owner"
  type        = string
}

variable "github_repository" {
  description = "The name of the GitHub repository"
  type        = string
}

variable "ses_from_email" {
  description = "The email address to use as the 'From' address for SES"
  type        = string
}

variable "ses_auto_reply_from_email" {
  description = "The email address to use as the 'From' address for SES auto-reply"
  type        = string
}

# Only published to GitHub as a secret. Not used in any AWS resource.
variable "contact_recipient_email" {
  description = "Address that receives contact form messages."
  type        = string
  sensitive   = true
}
