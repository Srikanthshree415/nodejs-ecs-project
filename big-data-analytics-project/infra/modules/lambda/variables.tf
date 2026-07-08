variable "role_name" {
  description = "IAM role for the Lambda function"
  type        = string
}

variable "filename" {
  description = "Path to the Lambda deployment package"
  type        = string
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "handler" {
  description = "Lambda handler"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "raw_bucket_arn" {
  description = "ARN of the raw S3 bucket"
  type        = string
}
