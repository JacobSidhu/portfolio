# Bootstrap

This folder creates the IAM role (and GitHub OIDC trust) that GitHub Actions assumes to deploy the main infrastructure. It is applied **manually from a local machine**, never by a pipeline, because a pipeline cannot create its own permissions (the chicken-and-egg problem).

## When to re-run

- First-time setup of the AWS account
- The deploy role needs new permissions (for example, adding CloudFront)
- The role or OIDC provider was deleted or changed
- You are setting up a fresh account or region

Day-to-day deployments do **not** need this.

## Prerequisites

- Terraform installed (see `required_version` in `terraform.tf`)
- AWS CLI installed
- An admin IAM or SSO user (never the root account) with MFA enabled
- The shared S3 state bucket already exists, with versioning on and public access blocked

## Steps

1. Clone the repo and go to the bootstrap folder:

   ```bash
   cd infra/terraform/bootstrap
   ```

2. Log in with your admin profile:

   ```bash
   aws sso login --profile admin
   export AWS_PROFILE=admin
   ```

3. Create `backend.hcl` in this folder. It is git-ignored, so never commit it:

   ```hcl
   bucket       = "your-state-bucket-name"
   key          = "terraform/bootstrap/portfolio/terraform.tfstate"
   region       = "eu-west-2"
   use_lockfile = true
   encrypt      = true
   ```

4. Initialise, review and apply:

   ```bash
   terraform init -backend-config=backend.hcl
   terraform plan
   terraform apply
   ```

5. Copy the role ARN from the outputs into the GitHub environment variable used by the workflows.

## Notes

- State lives in S3 under its own key, so a fresh clone picks up where you left off instead of recreating the role.
- `use_lockfile` stops two runs writing the state at once.
- CI only runs `terraform fmt -check -recursive` on this folder. It never applies it.
- Keep the role's permissions least-privilege: only the resources the main infrastructure manages, plus access to its own state keys.