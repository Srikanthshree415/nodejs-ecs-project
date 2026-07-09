variable "name_prefix" {
  description = "Prefix used for all analytics resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region for analytics resources"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for the analytics environment"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the EMR cluster"
  type        = list(string)
}

variable "raw_bucket_name" {
  description = "Name of the S3 bucket used for incoming sales CSV uploads"
  type        = string
  default     = ""
}

variable "processed_bucket_name" {
  description = "Name of the S3 bucket used for processed Parquet output"
  type        = string
  default     = ""
}

variable "sns_email_endpoint" {
  description = "Email endpoint for pipeline notifications"
  type        = string
}

variable "emr_master_instance_type" {
  description = "EMR master instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "emr_core_instance_type" {
  description = "EMR core instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "emr_core_instance_count" {
  description = "EMR core instance count"
  type        = number
  default     = 1
}
