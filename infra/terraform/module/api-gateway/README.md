# API Gateway module

Creates the HTTP API that sits in front of the whole site. The contact form goes to Lambda and every other GET is proxied to the S3 website endpoint.

| Route | Goes to |
| --- | --- |
| `POST /contact` | Contact Lambda |
| `GET /` | S3 website (`index.html`) |
| `GET /{proxy+}` | S3 website (everything else) |

## Usage

```hcl
module "api_gateway" {
  source              = "../../module/api-gateway"
  api_gateway_name    = "dev-portfolio-api"
  lambda_invoke_arn   = module.lambda.invoke_arn
  s3_website_endpoint = module.s3.website_endpoint
}
```

The `lambda` and `api_gateway` modules use each other's outputs. Terraform handles that fine: it creates the API first, then the function, then the integration and the invoke permission.

## Inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `api_gateway_name` | string | - | Required. |
| `lambda_invoke_arn` | string | - | Required. From `module.lambda.invoke_arn`. |
| `s3_website_endpoint` | string | - | Required. From `module.s3.website_endpoint`. Hostname only, no `http://`. |
| `cors_allow_origins` | list(string) | `["*"]` | Origins allowed to call `POST /contact`. Narrow it to the real domain once it's live. |
| `contact_throttle_burst_limit` | number | `2` | Burst limit on `POST /contact`. |
| `contact_throttle_rate_limit` | number | `5` | Requests per second on `POST /contact`. |

## Outputs

| Name | Description |
| --- | --- |
| `api_id` | Pass to the domain module. |
| `stage_id` | Pass to the domain module. |
| `execution_arn` | Pass to the lambda module for its invoke permission. |
| `api_endpoint` | Default `execute-api` URL. Useful before the custom domain is set up. |
| `api_contact_url` | Contact endpoint on the default URL. |

## Things to know

- The S3 website endpoint is HTTP only. Visitors still use HTTPS, because they talk to API Gateway, not S3.
- `{proxy+}` doesn't match the bare `/`, which is why there's a separate `GET /` route. Remove it and the home page returns 404.
- Throttling only applies to `POST /contact`. It's there to stop the form being used to spam through SES.
