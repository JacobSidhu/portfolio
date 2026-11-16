variable "api_gateway_name" {
  description = "Name of the HTTP API, e.g. dev-portfolio-api."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the contact Lambda."
  type        = string
}

# Pass module.s3.website_endpoint straight in.
variable "s3_website_endpoint" {
  description = "S3 website endpoint hostname, without http://."
  type        = string
}

# Tighten to the real site origin(s) once the custom domain is live.
variable "cors_allow_origins" {
  description = "Origins allowed to call POST /contact."
  type        = list(string)
  default     = ["*"]
}

variable "contact_throttle_burst_limit" {
  description = "Burst limit for POST /contact."
  type        = number
  default     = 2
}

variable "contact_throttle_rate_limit" {
  description = "Steady-state requests per second for POST /contact."
  type        = number
  default     = 5
}
