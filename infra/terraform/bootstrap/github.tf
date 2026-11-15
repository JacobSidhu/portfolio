resource "github_actions_environment_variable" "role_arn" {
  repository    = var.github_repository
  environment   = var.environment
  variable_name = "TERRAFORM_ROLE_ARN"
  value         = aws_iam_role.github_actions_terraform_role.arn
}
