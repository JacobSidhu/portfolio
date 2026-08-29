output "api_contact_url" {
  description = "Contact form API Gateway endpoint."
  value       = "${aws_apigatewayv2_stage.api_stage.invoke_url}/contact"
}
