variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string
}

# Only used for tagging at the moment.
variable "environment" {
  description = "Environment the bucket belongs to, e.g. dev or prod."
  type        = string
  default     = "dev"
}

# Leave as null in normal use. Handy for pointing at a different build folder
# when testing.
variable "dist_dir" {
  description = "Path to built website files. Defaults to the repository's dist directory."
  type        = string
  default     = null
}
