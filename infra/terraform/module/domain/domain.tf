# Custom domain for the HTTP API. Everything is behind enable_custom_domain so an
# environment can run on the default execute-api URL until DNS is ready.
#
# DNS isn't managed here. After the first apply starts, add the records from the
# domain_validation_options output at your DNS provider. Apply waits (up to the
# timeout below) until ACM sees them. Then point the domain at target_domain_name.
# See README.md in this folder for usage.

resource "aws_acm_certificate" "api" {
  count = var.enable_custom_domain ? 1 : 0

  domain_name       = var.portfolio_domain_name
  validation_method = "DNS"

  # Lets a replacement cert be issued and attached before the old one goes.
  lifecycle {
    create_before_destroy = true
  }
}

# Doesn't create anything. It just blocks until the cert is issued, so the
# custom domain below never gets an unvalidated cert.
resource "aws_acm_certificate_validation" "api" {
  count = var.enable_custom_domain ? 1 : 0

  certificate_arn = aws_acm_certificate.api[0].arn

  timeouts {
    create = "45m"
  }
}

resource "aws_apigatewayv2_domain_name" "api" {
  count = var.enable_custom_domain ? 1 : 0

  domain_name = var.portfolio_domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.api[0].certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api" {
  count = var.enable_custom_domain ? 1 : 0

  api_id      = var.api_id
  domain_name = aws_apigatewayv2_domain_name.api[0].domain_name
  stage       = var.stage_id
}
