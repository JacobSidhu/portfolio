# Contact form handler. API Gateway sends POST /contact here and the function
# emails the message through SES.
# See README.md in this folder for usage.

locals {
  source_dir = var.source_dir != null ? var.source_dir : "${path.module}/../../../../backend/lambda-functions/contact"
}

# Zips the source on every plan. The AWS SDK v3 is already in the Node.js 22
# runtime, so there's no npm install step and node_modules isn't needed.
# The zip goes under .terraform (git-ignored) instead of into the repo.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = "${path.root}/.terraform/build/${var.function_name}.zip"
}

# Created up front so retention is set. Otherwise Lambda makes the group itself
# on first run and keeps logs forever.
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "portfolio_lambda" {
  function_name = var.function_name

  # Role and its SES policy are created by bootstrap, not here.
  role = var.lambda_role_arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs22.x"
  timeout = 10

  environment {
    variables = {
      SES_FROM_EMAIL            = var.ses_from_email
      SES_AUTO_REPLY_FROM_EMAIL = var.ses_auto_reply_from_email
      CONTACT_RECIPIENT_EMAIL   = var.contact_recipient_email
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# Only POST /contact on this API can invoke the function.
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.portfolio_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/POST/contact"
}
