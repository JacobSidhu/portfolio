output "function_name" {
  description = "Lambda function name."
  value       = aws_lambda_function.portfolio_lambda.function_name
}

output "arn" {
  description = "Lambda function ARN."
  value       = aws_lambda_function.portfolio_lambda.arn
}

output "invoke_arn" {
  description = "Invoke ARN, used by the api-gateway module's integration."
  value       = aws_lambda_function.portfolio_lambda.invoke_arn
}
