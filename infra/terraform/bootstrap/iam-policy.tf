data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "terraform_permissions" {

  statement {
    sid     = "ManageProjectBuckets"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::portfolio-${var.environment}-site",
      "arn:aws:s3:::portfolio-${var.environment}-site/*",
    ]
  }

  statement {
    sid    = "StateAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}",
      "arn:aws:s3:::${var.state_bucket_name}/terraform/portfolio/${var.environment}/infra/*",
    ]
  }
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:jacobsidhu/portfolio:environment:dev*"]
    }
  }
}

resource "aws_iam_policy" "terraform_permissions" {
  name   = "github-actions-terraform-policy"
  policy = data.aws_iam_policy_document.terraform_permissions.json
}