terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}


terraform {
  backend "s3" {
    bucket         = "ecommerce-application-state-file" # your S3 bucket
    key            = "statefilestore/infra.tfstate"
    region         = "us-east-1" # Update to match your bucket region
    dynamodb_table = "statefile"
    encrypt        = true
  }
}
