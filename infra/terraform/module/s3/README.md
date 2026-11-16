# S3 module

Creates the bucket that hosts the portfolio site and uploads the built files from `dist/` into it.

The bucket is set up for S3 static website hosting and is publicly readable. API Gateway sits in front of it and forwards requests to the website endpoint, which is why `website_endpoint` is an output.

## What it creates

- `aws_s3_bucket.name` - the bucket itself, tagged with `Name` and `Environment`.
- `aws_s3_bucket_website_configuration.portfolio_website` - turns on website hosting. Both the index and error document are `index.html`, so unknown paths fall back to the app instead of returning the S3 error page.
- `aws_s3_bucket_public_access_block.portfolio_public_access` - all four block settings are off. The bucket policy below won't apply without this.
- `aws_s3_bucket_policy.portfolio_public_read` - allows anyone to `s3:GetObject`. Nothing else is public (no list, no write).
- `aws_s3_object.dist` - one object per file in the dist directory.

## Usage

Build the site first, then run Terraform from the environment folder.

```hcl
module "s3" {
  source      = "../../module/s3"
  bucket_name = var.site_bucket_name
  environment = var.environment
}
```

`envs/dev/main.tf` is the working example.

## Inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `bucket_name` | string | - | Required. Has to be globally unique. |
| `environment` | string | `"dev"` | Only used for the `Environment` tag. |
| `dist_dir` | string | `null` | Path to the built site. When left null it points at `dist/` in the repo root. |

## Outputs

| Name | Description |
| --- | --- |
| `bucket_id` | Bucket name. |
| `bucket_arn` | Bucket ARN. |
| `website_endpoint` | Website hostname, used by the API Gateway HTTP integration. |
| `website_domain` | Website domain, for DNS records. |

## How the file upload works

Terraform reads the dist directory with `fileset()` when it plans, so the folder has to exist and be up to date before you run `plan` or `apply`. If you forget to build, Terraform will either upload old files or try to delete everything that's in the bucket.

Each object's `etag` is the file's MD5, so only files that changed get re-uploaded.

Cache headers:

- `index.html` gets `no-cache` so a new deploy shows up straight away.
- Everything else gets `public, max-age=31536000, immutable`. This assumes asset filenames are hashed by the build. If you add a file to `public/` that keeps the same name between deploys, browsers may hang on to the old copy for up to a year.

Content types are picked from the file extension using the `content_types` map in `s3.tf`. Anything not in the map is uploaded as `application/octet-stream`. That currently includes `.ico`, `.txt`, `.xml`, `.woff` and `.woff2`, so add them to the map if the site starts using them.

## Things to know

- The bucket is public on purpose. If the AWS account has Block Public Access turned on at the account level, the bucket policy will fail to apply and you'll need to change that setting first.
- The S3 website endpoint only serves HTTP. HTTPS is handled in front of it.
- Deleting a file from `dist/` deletes it from the bucket on the next apply.
- The bucket resource is named `name`. It's a bit vague, but renaming it means a `moved` block or a state move, otherwise Terraform will try to destroy and recreate the bucket.
