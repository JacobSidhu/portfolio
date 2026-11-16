# SES sending identity for the contact form.
#
# Identities are per account and region, not per environment. If dev and prod
# share an AWS account and region, only one of them should create this, or the
# second apply fails because the identity already exists.
#
# To verify a domain identity, add the three DKIM CNAMEs from the dkim_tokens
# output at your DNS provider:
#   <token>._domainkey.<domain>  CNAME  <token>.dkim.amazonses.com
#
# New accounts are in the SES sandbox and can only send to verified addresses
# until production access is requested.
# See README.md in this folder for usage.
resource "aws_sesv2_email_identity" "portfolio_domain" {
  email_identity = var.email_identity
}
