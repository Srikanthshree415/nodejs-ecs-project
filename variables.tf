variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "nodej-ecs-capplication"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ECR Repository Configuration
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "nodejs-ecs-app"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "image_uri" {
  description = "Complete Docker image URI (optional - will be constructed if not provided)"
  type        = string
  default     = ""
}

# ECS Configuration Variables
variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units for the ECS task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for the ECS task (512, 1024, 2048, 4096, 8192)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
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
  default     = "/health"
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "NODE_ENV"
      value = "dev"
    }
  ]
}
  
# ALB Configuration Variables
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

# CloudWatch Configuration Variables
variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for CloudWatch alarms"
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for CloudWatch alarms"
  type        = number
  default     = 80
}

variable "alarm_actions" {
  description = "List of alarm actions (SNS topic ARNs)"
  type        = list(string)
  default     = []
}

# Deployment Configuration Variables
variable "enable_load_balancer" {
  description = "Enable ALB creation (set to false if AWS account doesn't support load balancers)"
  type        = bool
  default     = false
}

# # S3 Configuration Variables - CloudFormation Conversion
# variable "s3_stack_name" {
#   description = "Name for the S3 stack (equivalent to CloudFormation stack name)"
#   type        = string
#   default     = "s3-bucekt-convertion"
# }

# variable "s3_folders" {
#   description = "Set of folder names to create in the S3 bucket"
#   type        = set(string)
#   default     = ["documents", "data", "logs", "configs"]
# }

# variable "s3_files" {
#   description = "Map of files to upload to S3 bucket"
#   type = map(object({
#     source       = string
#     content_type = string
#   }))
#   default = {
#     "README.md" = {
#       source       = "../sample-files/README.md"
#       content_type = "text/markdown"
#     }
#     "configs/config.json" = {
#       source       = "../sample-files/config.json"
#       content_type = "application/json"
#     }
#     "data/data.csv" = {
#       source       = "../sample-files/data.csv"
#       content_type = "text/csv"
#     }
#   }
# }