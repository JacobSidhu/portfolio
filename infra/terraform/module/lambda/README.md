# Lambda module

Deploys the contact form handler from `backend/lambda-functions/contact`. API Gateway sends `POST /contact` here, and the function emails the message through SES and sends the visitor an auto-reply.

The execution role isn't created here. Bootstrap creates it, along with the policy that lets it send through SES.

## Usage

```hcl
module "lambda" {
  source                    = "../../module/lambda"
  function_name             = "dev-portfolio-contact"
  lambda_role_arn           = var.lambda_role_arn
  api_execution_arn         = module.api_gateway.execution_arn
  ses_from_email            = var.ses_from_email
  ses_auto_reply_from_email = var.ses_auto_reply_from_email
  contact_recipient_email   = var.contact_recipient_email
}
```

## Inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `function_name` | string | - | Required. Also names the log group. |
| `lambda_role_arn` | string | - | Required. The Lambda execution role from bootstrap. |
| `api_execution_arn` | string | - | Required. From `module.api_gateway.execution_arn`. |
| `ses_from_email` | string | - | Required. Sender for contact messages. |
| `ses_auto_reply_from_email` | string | - | Required. Sender for auto-replies. |
| `contact_recipient_email` | string | - | Required, sensitive. Where contact messages are delivered. |
| `source_dir` | string | `null` | Path to the function source. When null it points at `backend/lambda-functions/contact`. |
| `log_retention_days` | number | `14` | CloudWatch log retention. |

The function gets the three email addresses as the environment variables `SES_FROM_EMAIL`, `SES_AUTO_REPLY_FROM_EMAIL` and `CONTACT_RECIPIENT_EMAIL`.

## Outputs

| Name | Description |
| --- | --- |
| `invoke_arn` | Pass to the api-gateway module. |
| `function_name` | Function name. |
| `arn` | Function ARN. |

## Things to know

- **The sender addresses have to match bootstrap.** Both must be listed in `ses_from_email` and `ses_auto_reply_from_email` in the bootstrap `.tfvars`, or SES rejects the send with AccessDenied.
- **The role needs logging permissions.** Without `logs:CreateLogStream` and `logs:PutLogEvents` on the execution role, the function runs but writes no logs.
- **No `npm install` step.** The AWS SDK v3 is already in the Node.js 22 runtime, so only the source files are zipped.
- **The zip isn't committed.** It's built on every plan into `.terraform/build/`, which is git-ignored. A code change shows up in the plan as a new `source_code_hash`.
- **Only `POST /contact` can invoke the function.** The invoke permission is limited to that route on the given API.
