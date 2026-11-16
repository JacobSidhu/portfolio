# HTTP API that fronts the whole site:
#   POST /contact -> contact Lambda
#   GET  /        -> S3 website (index.html)
#   GET  /{proxy+} -> S3 website (everything else)
# See README.md in this folder for usage.

resource "aws_apigatewayv2_api" "api" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"

  # Only the contact form is called from the browser with fetch, so CORS
  # just needs to cover POST and its preflight.
  cors_configuration {
    allow_headers = ["Content-Type", "Accept"]
    allow_methods = ["OPTIONS", "POST"]
    allow_origins = var.cors_allow_origins
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
}

# S3 website endpoints are HTTP only. Clients still talk HTTPS to API Gateway.
resource "aws_apigatewayv2_integration" "s3_index_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.s3_website_endpoint}"
  payload_format_version = "1.0"

  # Pass the request path through so /assets/app.js fetches assets/app.js.
  request_parameters = {
    "overwrite:path" = "$request.path"
  }
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /contact"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# {proxy+} needs at least one path segment, so the bare root needs its own route
# or the home page returns 404.
resource "aws_apigatewayv2_route" "s3_root" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.s3_index_integration.id}"
}

resource "aws_apigatewayv2_route" "s3_index" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.s3_index_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  # Keeps the contact form from being used to spam SES.
  route_settings {
    route_key              = aws_apigatewayv2_route.lambda_route.route_key
    throttling_burst_limit = var.contact_throttle_burst_limit
    throttling_rate_limit  = var.contact_throttle_rate_limit
  }
}
