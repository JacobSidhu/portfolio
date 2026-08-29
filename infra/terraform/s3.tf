resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = var.portfolio_bucket_name
}
resource "aws_s3_bucket_website_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "portfolio_public_access" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "portfolio_public_read" {
  bucket = aws_s3_bucket.portfolio_bucket.id

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
        Resource  = "${aws_s3_bucket.portfolio_bucket.arn}/*"
      }
    ]
  })
}

locals {
  dist_files = fileset("${path.module}/../../dist", "**/*")

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

  bucket = aws_s3_bucket.portfolio_bucket.id
  key    = each.value
  source = "${path.module}/../../dist/${each.value}"
  etag   = filemd5("${path.module}/../../dist/${each.value}")

  content_type = lookup(
    local.content_types,
    lower(regex("[^.]+$", each.value)),
    "application/octet-stream"
  )
}
