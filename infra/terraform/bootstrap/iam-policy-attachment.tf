resource "aws_iam_role_policy_attachment" "github_actions_terraform_policy_attachment" {
  policy_arn = aws_iam_policy.terraform_permissions.arn
  role       = aws_iam_role.github_actions_terraform_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_execution_permission.arn
}
