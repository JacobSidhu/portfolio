resource "acm_certificate" "api" {
  count = var.enable_custom_domain ? 1 : 0

  validation_method = "DNS"
  domain_name       = var.portfolio_domain_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api" {
  count = var.enable_custom_domain ? 1 : 0

  certificate_arn = aws_acm_certificate.api[0].arn

  timeouts {
    create = "45m"
  }
}

resource "api_gatewayv2_domain_name" "api" {
  count = var.enable_custom_domain ? 1 : 0

  domain_name = var.portfolio_domain_name
  domain_name_configuration {
    certificate_arn = acm_certificate.api[0].arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "api_gatewayv2_api_mapping" "api" {
  count = var.enable_custom_domain ? 1 : 0

  api_id      = aws_apigatewayv2_api.api.id
  domain_name = api_gatewayv2_domain_name.api[0].domain_name
  stage       = aws_apigatewayv2_stage.api_stage.stage_name
}