# Everything returns null or [] when enable_custom_domain is false.

output "certificate_arn" {
  description = "ACM certificate ARN."
  value       = try(aws_acm_certificate.api[0].arn, null)
}

# Add these as CNAME records at your DNS provider to validate the certificate.
output "domain_validation_options" {
  description = "DNS records needed to validate the ACM certificate."
  value       = try(aws_acm_certificate.api[0].domain_validation_options, [])
}

output "domain_name" {
  description = "Custom domain name."
  value       = try(aws_apigatewayv2_domain_name.api[0].domain_name, null)
}

# Point the custom domain at this (CNAME, or an alias record in Route 53).
output "target_domain_name" {
  description = "Regional API Gateway hostname for the domain's DNS record."
  value       = try(aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].target_domain_name, null)
}

output "hosted_zone_id" {
  description = "API Gateway hosted zone ID, only needed for a Route 53 alias record."
  value       = try(aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].hosted_zone_id, null)
}
