resource "aws_iam_policy_attachment" "github_actions_terraform_policy_attachment" {
  name       = "github-actions-terraform-policy-attachment"
  policy_arn = aws_iam_policy.terraform_permissions.arn
  roles      = [aws_iam_role.github_actions_terraform_role.name]
}