resource "aws_s3_bucket" "name" {
  bucket = var.bucket_name

  tags = {
    Name        = "MyExampleBucket"
    Environment = var.environment
  }
}