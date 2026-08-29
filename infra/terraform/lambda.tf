data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../backend/lambda-functions/contact"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "portfolio_lambda" {
  function_name = "portfolio_lambda"
  role          = aws_iam_role.lambda_exec.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs22.x"
}