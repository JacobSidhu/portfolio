data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # envs/<env> names its Lambda "<env>-portfolio-contact" and its API
  # "<env>-portfolio-api". Scoping to this prefix keeps the dev role away
  # from prod's resources.
  resource_prefix = "${var.environment}-portfolio-"

  # SES identity the site sends from. Shared by every environment in the account.
  ses_identity_arn = "arn:aws:ses:${var.aws_region}:${local.account_id}:identity/jacobsidhu.com"

  lambda_log_group_arn = "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/lambda/${local.resource_prefix}*"
}

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

  # API Gateway uses HTTP verbs on resource paths instead of named actions.
  # PATCH is how Terraform updates routes, integrations and stages.
  # /domainnames/* also covers the API mappings under each domain.
  statement {
    sid    = "APIGatewayManagement"
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:PATCH",
      "apigateway:DELETE",
    ]
    resources = [
      "arn:aws:apigateway:${var.aws_region}::/apis",
      "arn:aws:apigateway:${var.aws_region}::/apis/*",
      "arn:aws:apigateway:${var.aws_region}::/domainnames",
      "arn:aws:apigateway:${var.aws_region}::/domainnames/*",
      "arn:aws:apigateway:${var.aws_region}::/tags/*",
    ]
  }

  statement {
    sid    = "LambdaManagement"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:GetRuntimeManagementConfig",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:ListVersionsByFunction",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:GetPolicy",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:ListTags",
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${local.account_id}:function:${local.resource_prefix}*",
    ]
  }

  # Needed to give the function its execution role. Locked to that one role,
  # and only when it's being handed to Lambda.
  statement {
    sid       = "PassLambdaRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.lambda_exec.arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["lambda.amazonaws.com"]
    }
  }

  statement {
    sid    = "LambdaLogGroups"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:DeleteRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource",
      "logs:ListTagsForResource",
      "logs:TagLogGroup",
      "logs:ListTagsLogGroup",
    ]
    resources = [
      local.lambda_log_group_arn,
      "${local.lambda_log_group_arn}:*",
    ]
  }

  # Can't be scoped. It's a list call, and Terraform uses it to read the group back.
  statement {
    sid       = "DescribeLogGroups"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }

  statement {
    sid    = "SESIdentity"
    effect = "Allow"
    actions = [
      "ses:CreateEmailIdentity",
      "ses:GetEmailIdentity",
      "ses:DeleteEmailIdentity",
      "ses:TagResource",
      "ses:UntagResource",
      "ses:ListTagsForResource",
    ]
    resources = [local.ses_identity_arn]
  }

  # A certificate has no ARN until it's requested, so this can't be scoped.
  statement {
    sid       = "RequestCertificate"
    effect    = "Allow"
    actions   = ["acm:RequestCertificate", "acm:AddTagsToCertificate"]
    resources = ["*"]
  }

  statement {
    sid    = "ManageCertificates"
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:DeleteCertificate",
      "acm:ListTagsForCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate",
    ]
    resources = ["arn:aws:acm:${var.aws_region}:${local.account_id}:certificate/*"]
  }
}

data "aws_iam_policy_document" "lambda_execution_permission" {
  statement {
    sid       = "SendPortfolioEmail"
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = [local.ses_identity_arn]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values = [
        var.ses_from_email,
        var.ses_auto_reply_from_email,
      ]
    }
  }

  # Terraform creates the log group, so the function only needs to write to it.
  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${local.lambda_log_group_arn}:*"]
  }
}

# GitHub now puts the owner and repo IDs in the OIDC subject
# (repo:Owner@123/repo@456:...), so look them up instead of hard-coding them.
# Pinning the IDs means a renamed or re-registered repo can't match this trust.
data "github_user" "owner" {
  username = var.github_owner
}

data "github_repository" "this" {
  full_name = "${var.github_owner}/${var.github_repository}"
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

    # Only jobs running in this repo's GitHub environment for the selected stage.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${data.github_user.owner.login}@${data.github_user.owner.id}/${data.github_repository.this.name}@${data.github_repository.this.repo_id}:environment:${var.environment}"
      ]
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
