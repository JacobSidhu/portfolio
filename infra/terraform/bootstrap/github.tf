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
