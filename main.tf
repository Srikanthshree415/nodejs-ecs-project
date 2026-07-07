# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.availability_zones
  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Use existing ECR Repository
data "aws_ecr_repository" "app" {
  name = var.ecr_repository_name
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "app" {
  repository = data.aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  common_tags = local.common_tags
  aws_region  = var.aws_region
}

# CloudWatch Module (without ALB metrics)
module "cloudwatch" {
  source = "./modules/cloudwatch"

  name_prefix            = local.name_prefix
  common_tags            = local.common_tags
  aws_region             = var.aws_region
  log_retention_days     = var.log_retention_days
  cpu_alarm_threshold    = var.cpu_alarm_threshold
  memory_alarm_threshold = var.memory_alarm_threshold
  alb_arn_suffix         = "" # No ALB available
  alarm_actions          = var.alarm_actions
}

# Simple ECS Cluster (No ALB - AWS account limitation) testing standalone container
resource "aws_ecs_cluster" "simple" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cluster"
  })
}

# # ECS Task Definition for standalone container
# resource "aws_ecs_task_definition" "simple" {
#   family                   = "${local.name_prefix}-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = var.cpu
#   memory                   = var.memory
#   execution_role_arn       = module.iam.ecs_task_execution_role_arn
#   task_role_arn            = module.iam.ecs_task_role_arn

#   container_definitions = jsonencode([
#     {
#       name      = "${local.name_prefix}-container"
#       image     = local.ecr_uri
#       essential = true

#       portMappings = [
#         {
#           containerPort = var.container_port
#           protocol      = "tcp"
#         }
#       ]

#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = module.cloudwatch.ecs_log_group_name
#           "awslogs-region"        = var.aws_region
#           "awslogs-stream-prefix" = "ecs"
#         }
#       }

#       environment = var.environment_variables
#     }
#   ])

#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-task-definition"
#   })
# }

# # Security Group for ECS Tasks (without ALB)
# resource "aws_security_group" "ecs_tasks" {
#   name        = "${local.name_prefix}-ecs-tasks-sg"
#   description = "Security group for ECS tasks"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "HTTP from anywhere (since no ALB)"
#     from_port   = var.container_port
#     to_port     = var.container_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-ecs-tasks-sg"
#   })
# }

# # ECS Service to run the task
# resource "aws_ecs_service" "simple" {
#   name            = "${local.name_prefix}-service"
#   cluster         = aws_ecs_cluster.simple.id
#   task_definition = aws_ecs_task_definition.simple.arn
#   desired_count   = var.desired_count
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = module.vpc.public_subnet_ids # Using public subnets since no ALB
#     security_groups  = [aws_security_group.ecs_tasks.id]
#     assign_public_ip = true # Need public IP since no ALB
#   }

#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-service"
#   })
# }

# # S3 Module - Converted from CloudFormation stack: s3-bucekt-convertion
# module "s3" {
#   source = "./modules/s3"

#   stack_name = var.s3_stack_name
#   tags       = local.common_tags

#   # Create folders in S3
#   folders = var.s3_folders

#   # Upload multiple files to S3
#   files = var.s3_files
# }
