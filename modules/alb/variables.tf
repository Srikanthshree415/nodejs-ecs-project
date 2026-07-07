variable "name_prefix" {
  description = "Name prefix for all ALB resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all ALB resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC where ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "container_port" {
  description = "Port on which the container is listening"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = ""
}

variable "enable_access_logs" {
  description = "Enable ALB access logs"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}
