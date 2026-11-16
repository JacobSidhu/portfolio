output "email_identity" {
  description = "SES identity (domain or email address)."
  value       = aws_sesv2_email_identity.portfolio_domain.email_identity
}

output "arn" {
  description = "SES identity ARN, for IAM sending permissions."
  value       = aws_sesv2_email_identity.portfolio_domain.arn
}

# Empty for an email-address identity. See ses.tf for the record format.
output "dkim_tokens" {
  description = "Easy DKIM tokens for the domain's DNS records."
  value       = try(aws_sesv2_email_identity.portfolio_domain.dkim_signing_attributes[0].tokens, [])
}
