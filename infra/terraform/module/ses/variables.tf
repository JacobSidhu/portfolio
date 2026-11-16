# Has to match the identity the Lambda role is allowed to send from in
# bootstrap/iam-policy.tf (currently identity/jacobsidhu.com).
variable "email_identity" {
  description = "Domain or email address to register as an SES sending identity."
  type        = string
}
