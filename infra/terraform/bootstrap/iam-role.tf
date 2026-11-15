resource "aws_iam_role" "github_actions_terraform_role" {
  name               = "github-actions-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}