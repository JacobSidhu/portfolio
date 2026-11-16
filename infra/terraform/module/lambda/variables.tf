# No defaults for names and addresses. They differ per environment and
# have to line up with what bootstrap allows the Lambda role to do.

variable "function_name" {
  description = "Name of the contact Lambda, e.g. dev-portfolio-contact."
  type        = string
}

# Output of bootstrap (the Lambda execution role).
variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role."
  type        = string
}

variable "api_execution_arn" {
  description = "Execution ARN of the HTTP API allowed to invoke the function."
  type        = string
}

variable "source_dir" {
  description = "Path to the contact Lambda source. Defaults to backend/lambda-functions/contact."
  type        = string
  default     = null
}

# Both sender addresses must be in the bootstrap lambda policy's ses:FromAddress list.
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

variable "log_retention_days" {
  description = "How long to keep the function's CloudWatch logs."
  type        = number
  default     = 14
}
