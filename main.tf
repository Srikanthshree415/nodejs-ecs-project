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

module "analytics" {
  source = "./modules/analytics"

  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  raw_bucket_name    = var.analytics_raw_bucket_name
  curated_bucket_name = var.analytics_curated_bucket_name
  sns_email_endpoint = var.analytics_sns_email_endpoint
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Use existing ECR Repository
data "aws_ecr_repository" "app" {
  name = var.ecr_repository_name
}



# # IAM Module
# module "iam" {
#   source = "./modules/iam"

#   name_prefix = local.name_prefix
#   common_tags = local.common_tags
#   aws_region  = var.aws_region
# }

# # CloudWatch Module (without ALB metrics)
# module "cloudwatch" {
#   source = "./modules/cloudwatch"

#   name_prefix            = local.name_prefix
#   common_tags            = local.common_tags
#   aws_region             = var.aws_region
#   log_retention_days     = var.log_retention_days
#   cpu_alarm_threshold    = var.cpu_alarm_threshold
#   memory_alarm_threshold = var.memory_alarm_threshold
#   alb_arn_suffix         = "" # No ALB available
#   alarm_actions          = var.alarm_actions
# }

# module "alb" {
#   source = "./modules/alb"

#   name_prefix                = local.name_prefix
#   common_tags                = local.common_tags
#   vpc_id                     = module.vpc.vpc_id
#   public_subnet_ids          = module.vpc.public_subnet_ids
#   container_port             = var.container_port
#   health_check_path          = var.health_check_path
#   enable_access_logs         = var.enable_access_logs
#   access_logs_bucket         = var.access_logs_bucket
#   enable_deletion_protection = var.enable_deletion_protection
#   certificate_arn            = var.certificate_arn
# }

# module "ecs" {
#   source = "./modules/ecs"

#   name_prefix           = local.name_prefix
#   common_tags           = local.common_tags
#   vpc_id                = module.vpc.vpc_id
#   private_subnet_ids    = module.vpc.private_subnet_ids
#   alb_security_group_id = module.alb.alb_security_group_id
#   target_group_arn      = module.alb.target_group_arn
#   execution_role_arn    = module.iam.ecs_task_execution_role_arn
#   task_role_arn         = module.iam.ecs_task_role_arn
#   log_group_name        = module.cloudwatch.ecs_log_group_name
#   aws_region            = var.aws_region
#   image_uri             = local.ecr_uri
#   container_port        = var.container_port
#   cpu                   = var.cpu
#   memory                = var.memory
#   desired_count         = var.desired_count
#   health_check_path     = var.health_check_path
#   environment_variables = var.environment_variables
# }

