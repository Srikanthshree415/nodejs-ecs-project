variable "name_prefix" {
  description = "Name prefix for all IAM resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all IAM resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region for IAM policies"
  type        = string
}