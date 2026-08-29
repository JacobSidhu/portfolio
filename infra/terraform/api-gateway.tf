resource "aws_apigatewayv2_api" "api" {
  name          = "portfolio-http-api-gtw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.portfolio_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST/contact"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}