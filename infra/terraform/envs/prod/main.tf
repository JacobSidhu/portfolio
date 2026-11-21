# Production environment. CD runs Terraform from this folder after building the site,
# and variables come in as TF_VAR_* env vars from the GitHub "prod" environment.
#
# Request flow: browser -> API Gateway -> S3 website (pages)
#                                      -> Lambda -> SES (contact form)

# Site bucket. Uploads everything in <repo root>/dist, so build before plan.
module "s3" {
  source      = "../../module/s3"
  bucket_name = var.site_bucket_name
  environment = var.environment
}

module "api-gateway" {
  source              = "../../module/api-gateway"
  api_gateway_name    = "${var.environment}-portfolio-api"
  lambda_invoke_arn   = module.lambda.invoke_arn
  s3_website_endpoint = module.s3.website_endpoint
}

# The execution role and its SES permissions come from bootstrap.
module "lambda" {
  source                    = "../../module/lambda"
  function_name             = "${var.environment}-portfolio-contact"
  lambda_role_arn           = var.lambda_role_arn
  api_execution_arn         = module.api-gateway.execution_arn
  ses_from_email            = var.ses_from_email
  ses_auto_reply_from_email = var.ses_auto_reply_from_email
  contact_recipient_email   = var.contact_recipient_email
}

# SES identities are per account and region. Dev already registers
# jacobsidhu.com, so this env only creates it when manage_ses_identity is true
# (e.g. a separate AWS account, or after moving ownership out of dev).
module "ses" {
  count          = var.manage_ses_identity ? 1 : 0
  source         = "../../module/ses"
  email_identity = var.ses_email_identity
}

# Off by default so apply doesn't sit waiting on certificate validation.
# Turn on once you're ready to add the DNS records.
module "domain" {
  source                = "../../module/domain"
  enable_custom_domain  = var.enable_custom_domain
  portfolio_domain_name = var.portfolio_domain_name
  api_id                = module.api-gateway.api_id
  stage_id              = module.api-gateway.stage_id
}

output "s3_bucket_name" {
  description = "Name of the bucket the site is deployed to."
  value       = module.s3.bucket_id
}

output "site_url" {
  description = "Where to open the site. The custom domain once enabled, otherwise the execute-api URL."
  value       = var.enable_custom_domain ? "https://${var.portfolio_domain_name}" : module.api-gateway.api_endpoint
}

output "api_contact_url" {
  description = "Contact form endpoint on the execute-api URL."
  value       = module.api-gateway.api_contact_url
}

# DNS records to add by hand. See module/domain and module/ses READMEs.
output "certificate_validation_records" {
  description = "CNAMEs that validate the ACM certificate."
  value       = module.domain.domain_validation_options
}

output "domain_target" {
  description = "Hostname the custom domain's CNAME should point at."
  value       = module.domain.target_domain_name
}

output "ses_dkim_tokens" {
  description = "Tokens for the SES DKIM CNAMEs."
  value       = var.manage_ses_identity ? module.ses[0].dkim_tokens : null
}
