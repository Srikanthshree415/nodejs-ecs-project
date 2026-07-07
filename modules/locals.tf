locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  name_prefix       = "${var.project_name}-${var.environment}"
  short_name_prefix = "njsapp-${var.environment}"

  # Dynamic ECR URI construction
  ecr_uri = var.image_uri != "" ? var.image_uri : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}:${var.image_tag}"
}


