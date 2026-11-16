# Domain module

Puts the HTTP API on a custom domain. It creates an ACM certificate, waits for it to be validated, creates the API Gateway custom domain and maps it to the API's stage.

Everything is behind `enable_custom_domain`, so an environment can run on the default `execute-api` URL until DNS is ready.

## Usage

```hcl
module "domain" {
  source                = "../../module/domain"
  portfolio_domain_name = "dev.jacobsidhu.com"
  api_id                = module.api_gateway.api_id
  stage_id              = module.api_gateway.stage_id
}
```

To turn it off for an environment:

```hcl
  enable_custom_domain = false
```

## Inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `portfolio_domain_name` | string | - | Required. Each environment needs its own hostname. |
| `api_id` | string | - | Required. From `module.api_gateway.api_id`. |
| `stage_id` | string | - | Required. From `module.api_gateway.stage_id`. |
| `enable_custom_domain` | bool | `true` | `false` skips everything in this module. |

## Outputs

All of these are `null` (or `[]`) when `enable_custom_domain` is `false`.

| Name | Description |
| --- | --- |
| `domain_validation_options` | CNAME records to add so ACM can validate the certificate. |
| `target_domain_name` | Hostname to point the custom domain at. |
| `hosted_zone_id` | Only needed for a Route 53 alias record. |
| `certificate_arn` | ACM certificate ARN. |
| `domain_name` | The custom domain. |

## DNS setup

DNS isn't managed by this module, so the first apply needs a hand:

1. Run apply. It creates the certificate and then waits for validation, for up to 45 minutes.
2. While it waits, add the records from `domain_validation_options` at your DNS provider. You can see them in the AWS console under ACM, or with `terraform output` once a run finishes.
3. Once ACM sees the records, apply carries on and creates the custom domain.
4. Add a CNAME from your domain to `target_domain_name`.

If apply times out before the records are in, add them and run apply again.

## Things to know

- The certificate is created in the provider's region, which is what a regional API Gateway domain needs. It's not a CloudFront certificate, so it doesn't have to be in `us-east-1`.
- Leave the validation records in place. ACM uses them to renew the certificate.
