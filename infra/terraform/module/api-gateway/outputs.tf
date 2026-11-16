output "api_id" {
  description = "API ID, used by the domain module for the API mapping."
  value       = aws_apigatewayv2_api.api.id
}

output "execution_arn" {
  description = "Execution ARN, used by the lambda module for its invoke permission."
  value       = aws_apigatewayv2_api.api.execution_arn
}

output "stage_id" {
  description = "Stage ID, used by the domain module for the API mapping."
  value       = aws_apigatewayv2_stage.api_stage.id
}

output "api_endpoint" {
  description = "Default execute-api URL. Works before the custom domain is set up."
  value       = aws_apigatewayv2_stage.api_stage.invoke_url
}

output "api_contact_url" {
  description = "Contact form endpoint on the default execute-api URL."
  value       = "${aws_apigatewayv2_stage.api_stage.invoke_url}/contact"
}
