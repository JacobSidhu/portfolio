data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_permissions" {

  statement {
    sid     = "ManageProjectBuckets"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.site_bucket_name}",
      "arn:aws:s3:::${var.site_bucket_name}/*",
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
      "arn:aws:s3:::${var.site_state_bucket_name}",
      "arn:aws:s3:::${var.site_state_bucket_name}/${var.site_state_key}",
      "arn:aws:s3:::${var.site_state_bucket_name}/${var.site_state_key}.tflock",
    ]
  }
}

data "aws_iam_policy_document" "lambda_execution_permission" {
  statement {
    sid       = "SendPortfolioEmail"
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = ["arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.current.account_id}:identity/jacobsidhu.com"]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values = [
        var.ses_from_email,
        var.ses_auto_reply_from_email,
      ]
    }
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
      values   = ["repo:${var.github_owner}/${var.github_repository}:environment:${var.environment}"]
    }
  }
}

resource "aws_iam_policy" "lambda_execution_permission" {
  name   = var.lambda_policy_name
  policy = data.aws_iam_policy_document.lambda_execution_permission.json
}

resource "aws_iam_policy" "terraform_permissions" {
  name   = var.terraform_policy_name
  policy = data.aws_iam_policy_document.terraform_permissions.json
}
