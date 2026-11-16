# Dev environment. CD runs Terraform from this folder after building the site,
# and variables come in as TF_VAR_* env vars from the GitHub "dev" environment.

# Site bucket. Uploads everything in <repo root>/dist, so build before plan.
module "s3" {
  source      = "../../module/s3"
  bucket_name = var.site_bucket_name
  environment = var.environment
}

output "s3_bucket_name" {
  description = "Name of the bucket the site is deployed to."
  value       = module.s3.bucket_id
}
