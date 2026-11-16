# Hosts the built portfolio site. API Gateway proxies to the website endpoint,
# so the bucket needs website hosting on and public read access.
# See README.md in this folder for usage.

# Don't rename this resource without a moved block, or Terraform will
# destroy and recreate the bucket.
resource "aws_s3_bucket" "name" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.name.id

  index_document {
    suffix = "index.html"
  }

  # Send unknown paths back to index.html instead of the S3 error page.
  error_document {
    key = "index.html"
  }
}

# Public on purpose. These have to be off or the bucket policy below is rejected.
# Account-level Block Public Access also has to allow it.
resource "aws_s3_bucket_public_access_block" "portfolio_public_access" {
  bucket = aws_s3_bucket.name.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Read-only for everyone. No list or write access.
resource "aws_s3_bucket_policy" "portfolio_public_read" {
  bucket = aws_s3_bucket.name.id

  # Applying the policy before the access block is relaxed fails with AccessDenied.
  depends_on = [
    aws_s3_bucket_public_access_block.portfolio_public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.name.arn}/*"
      }
    ]
  })
}

locals {
  # Falls back to <repo root>/dist.
  dist_dir = var.dist_dir != null ? var.dist_dir : "${path.module}/../../../../dist"

  # Read at plan time, so build the site before running plan/apply.
  # An empty or missing dist folder means Terraform will delete every object.
  dist_files = fileset(local.dist_dir, "**/*")

  # S3 doesn't guess content types, so we set them from the extension.
  # Anything not listed here goes up as application/octet-stream.
  content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    svg  = "image/svg+xml"
    webp = "image/webp"
    pdf  = "application/pdf"
  }
}

resource "aws_s3_object" "dist" {
  for_each = local.dist_files

  bucket = aws_s3_bucket.name.id
  key    = each.value
  source = "${local.dist_dir}/${each.value}"

  # Changes when the file changes, so only edited files get re-uploaded.
  etag = filemd5("${local.dist_dir}/${each.value}")

  # index.html is never cached so new deploys show up right away.
  # Everything else is cached for a year, which relies on the build hashing
  # asset filenames. Files with fixed names can go stale in browsers.
  cache_control = each.value == "index.html" ? "no-cache" : "public, max-age=31536000, immutable"

  # Takes whatever comes after the last dot, e.g. "assets/app.JS" -> "js".
  content_type = lookup(
    local.content_types,
    lower(regex("[^.]+$", each.value)),
    "application/octet-stream"
  )
}