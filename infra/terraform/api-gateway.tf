resource "aws_apigatewayv2_api" "api" {
  name          = "portfolio-http-api-gtw"
  protocol_type = "HTTP"
}