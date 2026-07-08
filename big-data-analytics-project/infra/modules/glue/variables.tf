variable "database_name" {
  description = "Glue catalog database name"
  type        = string
}

variable "crawler_name" {
  description = "Glue crawler name"
  type        = string
}

variable "crawler_role_arn" {
  description = "IAM role ARN used by the Glue crawler"
  type        = string
}

variable "s3_target_path" {
  description = "S3 path targeted by the crawler"
  type        = string
}
