# Bootstrap

Run bootstrap locally to create the environment's IAM deployment role, Lambda execution role, policies, and policy attachments. The deployment role trusts GitHub Actions through an existing GitHub OIDC provider. Terraform also manages the matching GitHub environment, deployment branch policies, and seven Actions variables.

Re-run bootstrap when setting up an environment or changing the deployment role's permissions or trust policy. Day-to-day infrastructure deployments use the role through CD.

## Prerequisites

- PowerShell and AWS CLI installed.
- Terraform 1.15.0 or newer installed. Provider requirements are in `terraform.tf`.
- An AWS profile with permission to manage the bootstrap IAM resources and access the state bucket.
- An existing S3 state bucket with versioning enabled and public access blocked.
- An existing GitHub OIDC provider in the target AWS account for `https://token.actions.githubusercontent.com`.
- GitHub authentication with permission to manage repository environments and their Actions variables. Bootstrap creates the selected `dev`, `stag`, or `prod` environment. Import an existing environment into Terraform state before managing it with bootstrap.

## Configure local authentication

Open PowerShell and select your AWS profile. For an SSO profile, log in first.

```powershell
aws sso login --profile bootstrap-runner
$env:AWS_PROFILE = "bootstrap-runner"
aws sts get-caller-identity
```

For a profile created through AWS console login, use `aws login --profile bootstrap-runner` to sign in.

The GitHub provider reads `GITHUB_TOKEN` from the current session. If you use GitHub CLI, authenticate and pass its token to the provider.

```powershell
gh auth login
$env:GITHUB_TOKEN = gh auth token
```

## Configure Terraform inputs

Go to the bootstrap directory and edit the selected environment's file, `dev.tfvars`, `stag.tfvars`, or `prod.tfvars`. These files are git-ignored by the repository's `*.tfvars` rule.

| Script selection | Variables file |
| --- | --- |
| `-Environment dev` | `dev.tfvars` |
| `-Environment stag` | `stag.tfvars` |
| `-Environment prod` | `prod.tfvars` |

Each file contains the complete set of bootstrap inputs for its environment. Keep the `environment` value aligned with the filename. The example below shows `dev.tfvars`.

```powershell
cd infra/terraform/bootstrap
```

```hcl
environment                 = "dev"
aws_region                  = "eu-west-2"
terraform_role_name         = "dev-github-actions-terraform-role"
terraform_policy_name       = "dev-github-actions-terraform-role-policy"
lambda_role_name            = "dev-portfolio-role-lambda-exec"
lambda_policy_name          = "dev-portfolio-role-lambda-exec-policy"
site_bucket_name            = "portfolio-dev-site"
bootstrap_state_bucket_name = "jacobsidhu"
site_state_bucket_name      = "jacobsidhu"
site_state_key              = "terraform/portfolio/dev/infra/terraform.tfstate"
github_owner                = "jacobsidhu"
github_repository           = "portfolio"
ses_from_email              = "dev-portfolio@jacobsidhu.com"
ses_auto_reply_from_email   = "dev-autoreply@jacobsidhu.com"
```

`bootstrap_state_bucket_name` is published to GitHub as `BOOTSTRAP_STATE_BUCKET_NAME`. The script configures the actual bootstrap backend separately through `-StateBucket`, so keep those values aligned. `site_state_bucket_name` controls the deployment role's permissions for the main infrastructure state bucket and is published as `SITE_STATE_BUCKET_NAME`.

Role names, policy names, the site bucket name, and the main infrastructure state key are literal values in each environment file. Terraform uses those values directly. Put the full desired names in the file, including any environment prefix you want.

The script loads `<environment>.tfvars` with `-var-file` and supplies the selected environment on the command line. The OIDC trust policy uses `github_owner`, `github_repository`, and the selected environment.

## Plan and apply

```powershell
.\bootstrap.ps1 -Environment dev -Action plan
.\bootstrap.ps1 -Environment dev -Action apply
```

The script defaults to `plan`. If you omit `-Environment`, it prompts for `dev`, `stag`, or `prod`.

When invoking Terraform directly after initialising the matching backend, pass the environment file explicitly for every plan, apply, or destroy command.

```powershell
terraform plan "-var-file=dev.tfvars"
terraform apply "-var-file=dev.tfvars"
terraform destroy "-var-file=dev.tfvars"
```

Each run writes the git-ignored `backend.hcl`, enables S3 locking and encryption, and runs `terraform init -reconfigure`. It then runs the selected Terraform action with the matching environment input. Terraform asks for confirmation before applying changes.

The state bucket defaults to `jacobsidhu` and its region defaults to `eu-west-2`. Override them when needed.

```powershell
.\bootstrap.ps1 -Environment dev -Action plan -StateBucket "your-state-bucket" -StateRegion "eu-west-2"
```

`-StateRegion` selects the backend bucket's region. The `aws_region` Terraform input configures the AWS provider separately.

After apply succeeds, Terraform manages these variables in the selected GitHub environment.

| GitHub variable | Value |
| --- | --- |
| `ENVIRONMENT` | Selected environment |
| `AWS_REGION` | `aws_region` input |
| `TERRAFORM_ROLE_ARN` | Created deployment role ARN |
| `SITE_BUCKET_NAME` | `site_bucket_name` input |
| `SITE_STATE_BUCKET_NAME` | `site_state_bucket_name` input |
| `SITE_STATE_KEY` | `site_state_key` input |
| `BOOTSTRAP_STATE_BUCKET_NAME` | `bootstrap_state_bucket_name` input |

CD can read the role ARN through `${{ vars.TERRAFORM_ROLE_ARN }}` when its job selects that environment. You can also inspect the saved output locally.

```powershell
terraform output -raw github-runner-terraform-role-arn
```

## Switch environments

```powershell
.\bootstrap.ps1 -Environment stag -Action plan
.\bootstrap.ps1 -Environment stag -Action apply
```

The script selects separate bootstrap state keys for each environment.

| Environment | State key |
| --- | --- |
| `dev` | `terraform/portfolio/dev/bootstrap/terraform.tfstate` |
| `stag` | `terraform/portfolio/stag/bootstrap/terraform.tfstate` |
| `prod` | `terraform/portfolio/prod/bootstrap/terraform.tfstate` |

The script selects the matching `.tfvars` file. IAM role and policy names come directly from that file, and its site bucket and state key values determine the deployment role's resource permissions. The OIDC trust and GitHub environment use the selected environment.

Update the selected `.tfvars` file's account-specific values and select the matching AWS profile when using a different AWS account. Pass `-StateBucket` and `-StateRegion` if its backend differs. Bootstrap manages a GitHub environment for each selected environment.

Use an existing environment's original bucket and key to continue managing its resources. If bootstrap was previously applied under a different state key, plan its state migration before using the script's generated key.

## Destroy bootstrap

Destroy the main infrastructure first if deployment access depends on this role. Then run the script for the environment you want to remove.

```powershell
.\bootstrap.ps1 -Environment dev -Action destroy
```

Terraform shows the proposed deletions and asks for confirmation. This removes the managed deployment and Lambda roles, policies, policy attachments, deployment branch policies, all seven Actions variables listed above, and the selected GitHub environment. Deleting that GitHub environment also removes any additional environment variables, secrets, and protection rules attached to it. The existing S3 bucket and OIDC provider are managed separately.

## CI validation

The bootstrap workflow runs backend-disabled initialisation, `terraform fmt -check`, and `terraform validate` on relevant pull requests. Applying and destroying bootstrap are local operations.
