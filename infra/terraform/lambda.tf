resource "aws_lambda_function" "portfolio_lambda" {
    function_name = "portfolio_lambda"
    role          = aws_iam_role.portfolio_role_lambda_exec.arn
    handler       = "contact/index.handler"
    runtime       = "nodejs18.x"
}