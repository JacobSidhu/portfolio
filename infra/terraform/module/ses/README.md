# SES module

Registers the SES sending identity the contact form sends from. It can be a whole domain or a single email address.

## Usage

```hcl
module "ses" {
  source         = "../../module/ses"
  email_identity = "jacobsidhu.com"
}
```

## Inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `email_identity` | string | - | Required. Domain or email address. Must match the identity in the Lambda policy in `bootstrap/iam-policy.tf`. |

## Outputs

| Name | Description |
| --- | --- |
| `email_identity` | The identity that was registered. |
| `arn` | Identity ARN, for IAM sending permissions. |
| `dkim_tokens` | Easy DKIM tokens. Empty for a single email address. |

## Verifying a domain

Add three CNAME records at your DNS provider, one for each token in `dkim_tokens`:

```
<token>._domainkey.jacobsidhu.com  CNAME  <token>.dkim.amazonses.com
```

The identity shows as verified in the SES console once AWS picks them up, which can take a while.

For a single email address, AWS sends a verification email instead. Click the link in it.

## Things to know

- **Identities are per AWS account and region, not per environment.** If dev and prod share an account and region, only one of them should create the identity. Otherwise the second apply fails because it already exists.
- **New accounts are in the SES sandbox.** In the sandbox you can only send to verified addresses, so the auto-reply to visitors won't work until you request production access in the SES console.
