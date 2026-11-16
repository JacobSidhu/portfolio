output "github-runner-terraform-role-arn" {
  value = aws_iam_role.github_actions_terraform_role.arn
}