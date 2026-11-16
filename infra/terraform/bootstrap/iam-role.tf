resource "aws_iam_role" "github_actions_terraform_role" {
  name               = var.terraform_role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role" "lambda_exec" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
