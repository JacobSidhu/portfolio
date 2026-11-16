variable "enable_custom_domain" {
  description = "Create the certificate, custom domain and API mapping."
  type        = bool
  default     = true
}

# No default on purpose. Each environment needs its own hostname,
# e.g. dev.jacobsidhu.com for dev and www.jacobsidhu.com for prod.
variable "portfolio_domain_name" {
  description = "Hostname to serve the site on."
  type        = string
}

variable "api_id" {
  description = "HTTP API to map to the domain (module.api_gateway.api_id)."
  type        = string
}

variable "stage_id" {
  description = "Stage to map to the domain (module.api_gateway.stage_id)."
  type        = string
}
