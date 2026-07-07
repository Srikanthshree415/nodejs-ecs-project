variable "name_prefix" {
  description = "Name prefix for all CloudWatch resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all CloudWatch resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region for CloudWatch resources"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  type        = string
  default     = ""
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "alarm_actions" {
  description = "List of alarm actions (SNS topic ARNs)"
  type        = list(string)
  default     = []
}
