terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source = "./modules/s3"

  raw_bucket_name     = var.raw_bucket_name
  curated_bucket_name = var.curated_bucket_name
}

module "lambda" {
  source = "./modules/lambda"

  role_name      = "sales-lambda-exec-role"
  filename       = var.lambda_zip_path
  function_name  = "validate-sales-file"
  handler        = "handler.lambda_handler"
  runtime        = "python3.11"
  timeout        = 60
  raw_bucket_arn = module.s3.raw_bucket_arn
}

module "stepfunctions" {
  source = "./modules/stepfunctions"

  role_name             = "sales-stepfunctions-role"
  state_machine_name    = "sales-pipeline"
  lambda_function_arn   = module.lambda.lambda_function_arn
  lambda_function_name  = module.lambda.lambda_function_name
  sns_topic_arn         = module.sns.topic_arn
}

module "emr" {
  source = "./modules/emr"

  service_role_name       = "sales-emr-service-role"
  cluster_name            = "sales-emr-cluster"
  subnet_id               = var.subnet_id
  master_security_group_id = var.master_security_group_id
  slave_security_group_id  = var.slave_security_group_id
  instance_profile_arn    = var.instance_profile_arn
  raw_bucket_arn          = module.s3.raw_bucket_arn
  curated_bucket_arn      = module.s3.curated_bucket_arn
}

module "iam" {
  source = "./modules/iam"

  role_name         = "sales-glue-crawler-role"
  raw_bucket_arn    = module.s3.raw_bucket_arn
  curated_bucket_arn = module.s3.curated_bucket_arn
}

module "glue" {
  source = "./modules/glue"

  database_name    = "sales_db"
  crawler_name     = "sales-crawler"
  crawler_role_arn = module.iam.role_arn
  s3_target_path   = "s3://${module.s3.curated_bucket_name}/sales/"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  lambda_function_name = module.lambda.lambda_function_name
}

module "sns" {
  source = "./modules/sns"

  topic_name      = var.sns_topic_name
  email_endpoint  = var.sns_email_endpoint
}
