output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository (existing)"
  value       = data.aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository (existing)"
  value       = data.aws_ecr_repository.app.name
}

# Simple ECS Outputs (No ALB due to AWS account restrictions)
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.simple.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.simple.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.simple.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.simple.id
}

# CloudWatch Outputs
output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.cloudwatch.dashboard_url
}

output "ecs_log_group_name" {
  description = "Name of the ECS log group"
  value       = module.cloudwatch.ecs_log_group_name
}

# Simple ECS Task Definition Outputs
output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.simple.arn
}

output "ecs_task_definition_family" {
  description = "Family of the ECS task definition"
  value       = aws_ecs_task_definition.simple.family
}

# IAM Outputs
output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.iam.ecs_task_role_arn
}

# ECR and Image Information
output "image_uri_used" {
  description = "The final image URI used for deployment"
  value       = local.ecr_uri
}

output "aws_account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

# S3 Outputs - CloudFormation Conversion
output "s3_bucket_id" {
  description = "ID/name of the S3 bucket (converted from CloudFormation)"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket (converted from CloudFormation)"
  value       = module.s3.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket (converted from CloudFormation)"
  value       = module.s3.bucket_domain_name
}

output "s3_folders_created" {
  description = "List of folders created in the S3 bucket"
  value       = module.s3.folders_created
}

output "s3_files_uploaded" {
  description = "Map of files uploaded to S3 bucket with their URLs"
  value       = module.s3.files_uploaded
}


