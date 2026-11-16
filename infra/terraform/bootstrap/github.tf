locals {
  # Branches allowed to deploy to each environment. Prod is main only.
  deployment_branches = {
    dev  = ["main", "ui/home"]
    stag = ["main"]
    prod = ["main"]
  }
}

resource "github_repository_environment" "this" {
  repository  = var.github_repository
  environment = var.environment

  # Switch the environment to "selected branches" mode.
  # Exactly one of these two must be true.
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

# One resource per allowed branch pattern.
resource "github_repository_environment_deployment_policy" "this" {
  for_each = toset(local.deployment_branches[var.environment])

  repository     = var.github_repository
  environment    = github_repository_environment.this.environment
  branch_pattern = each.value
}


resource "github_actions_environment_variable" "environment" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "ENVIRONMENT"
  value         = var.environment
}

resource "github_actions_environment_variable" "aws_region" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "AWS_REGION"
  value         = var.aws_region
}

resource "github_actions_environment_variable" "role_arn" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "TERRAFORM_ROLE_ARN"
  value         = aws_iam_role.github_actions_terraform_role.arn
}

resource "github_actions_environment_variable" "site_bucket_name" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "SITE_BUCKET_NAME"
  value         = var.site_bucket_name
}

resource "github_actions_environment_variable" "site_state_bucket_name" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "SITE_STATE_BUCKET_NAME"
  value         = var.site_state_bucket_name
}

resource "github_actions_environment_variable" "site_state_key" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "SITE_STATE_KEY"
  value         = var.site_state_key
}

resource "github_actions_environment_variable" "bootstrap_state_bucket_name" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "BOOTSTRAP_STATE_BUCKET_NAME"
  value         = var.bootstrap_state_bucket_name
}

# Used by the lambda module in envs/<env>.
resource "github_actions_environment_variable" "lambda_role_arn" {
  repository    = var.github_repository
  environment   = github_repository_environment.this.environment
  variable_name = "LAMBDA_ROLE_ARN"
  value         = aws_iam_role.lambda_exec.arn
}

# Email addresses are secrets so they're masked in workflow logs. The sender
# addresses come from the same inputs as the Lambda role's ses:FromAddress
# condition, so the function can only be given addresses it's allowed to use.
#
# Values end up in plain text in the bootstrap state file, which is why the
# state bucket must stay private and encrypted.
resource "github_actions_environment_secret" "ses_from_email" {
  repository  = var.github_repository
  environment = github_repository_environment.this.environment
  secret_name = "SES_FROM_EMAIL"
  value       = var.ses_from_email
}

resource "github_actions_environment_secret" "ses_auto_reply_from_email" {
  repository  = var.github_repository
  environment = github_repository_environment.this.environment
  secret_name = "SES_AUTO_REPLY_FROM_EMAIL"
  value       = var.ses_auto_reply_from_email
}

# Overrides the old repository-level CONTACT_RECIPIENT_EMAIL secret for this
# environment.
resource "github_actions_environment_secret" "contact_recipient_email" {
  repository  = var.github_repository
  environment = github_repository_environment.this.environment
  secret_name = "CONTACT_RECIPIENT_EMAIL"
  value       = var.contact_recipient_email
}
