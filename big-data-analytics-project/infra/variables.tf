variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "raw_bucket_name" {
  description = "Name of the S3 bucket for incoming raw sales CSV files"
  type        = string
}

variable "curated_bucket_name" {
  description = "Name of the S3 bucket for curated Parquet data"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for pipeline notifications"
  type        = string
  default     = "sales-pipeline-alerts"
}

variable "sns_email_endpoint" {
  description = "Email endpoint for SNS notifications"
  type        = string
  default     = "example@example.com"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "../src/lambda/validate_file/package.zip"
}

variable "subnet_id" {
  description = "Subnet ID for EMR cluster"
  type        = string
  default     = "subnet-00000000000000000"
}

variable "master_security_group_id" {
  description = "Security group for EMR master node"
  type        = string
  default     = "sg-00000000000000000"
}

variable "slave_security_group_id" {
  description = "Security group for EMR slave nodes"
  type        = string
  default     = "sg-00000000000000000"
}

variable "instance_profile_arn" {
  description = "EC2 instance profile ARN for EMR"
  type        = string
  default     = "arn:aws:iam::123456789012:instance-profile/emr-ec2-default-role"
}

variable "glue_crawler_role_arn" {
  description = "IAM role ARN for the Glue crawler"
  type        = string
  default     = "arn:aws:iam::123456789012:role/AWSGlueServiceRole-default"
}
