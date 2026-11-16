output "bucket_id" {
  description = "S3 bucket ID (same as the bucket name)."
  value       = aws_s3_bucket.name.id
}

output "bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.name.arn
}

# Hostname only, no scheme. The website endpoint is HTTP only, so add
# http:// when building the integration URI.
output "website_endpoint" {
  description = "S3 website endpoint hostname for the API Gateway HTTP integration."
  value       = aws_s3_bucket_website_configuration.portfolio_website.website_endpoint
}

output "website_domain" {
  description = "S3 website domain for DNS configuration."
  value       = aws_s3_bucket_website_configuration.portfolio_website.website_domain
}
