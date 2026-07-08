variable "service_role_name" {
  description = "IAM service role for EMR"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EMR cluster"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EMR instances"
  type        = string
}

variable "master_security_group_id" {
  description = "Security group for EMR master node"
  type        = string
}

variable "slave_security_group_id" {
  description = "Security group for EMR slave nodes"
  type        = string
}

variable "instance_profile_arn" {
  description = "EC2 instance profile ARN for EMR"
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
