variable "role_name" {
  description = "IAM role name"
  type        = string
}

variable "raw_bucket_arn" {
  description = "ARN of the raw S3 bucket"
  type        = string
}

variable "curated_bucket_arn" {
  description = "ARN of the curated S3 bucket"
  type        = string
}
