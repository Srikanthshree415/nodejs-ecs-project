variable "name_prefix" {
  description = "Name prefix for all ECS resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all ECS resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC where ECS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "aws_region" {
  description = "AWS region for ECS resources"
  type        = string
}

variable "image_uri" {
  description = "Docker image URI"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for the task (512, 1024, 2048, 4096, 8192)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70.0
}

variable "memory_target_value" {
  description = "Target memory utilization for auto scaling"
  type        = number
  default     = 80.0
}

variable "health_check_path" {
  description = "Health check path for the application"
  type        = string
  default     = "/"
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}