terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

locals {
  raw_bucket_name     = var.raw_bucket_name != "" ? var.raw_bucket_name : "${var.name_prefix}-sales-raw"
  curated_bucket_name = var.curated_bucket_name != "" ? var.curated_bucket_name : "${var.name_prefix}-sales-curated"
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda-package.zip"
  source_file = "${path.module}/../../big-data/lambda/validate_sales_file.py"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "raw" {
  bucket = local.raw_bucket_name
  tags   = var.common_tags
}

resource "aws_s3_bucket" "curated" {
  bucket = local.curated_bucket_name
  tags   = var.common_tags
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "spark_script" {
  bucket = aws_s3_bucket.raw.id
  key    = "scripts/sales_etl.py"
  source = "${path.module}/../../big-data/spark/sales_etl.py"
  etag   = filemd5("${path.module}/../../big-data/spark/sales_etl.py")
}

resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}-analytics-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3" {
  name = "${var.name_prefix}-analytics-lambda-s3"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw.arn,
          "${aws_s3_bucket.raw.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_sfn" {
  name = "${var.name_prefix}-analytics-lambda-sfn"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = [
          "arn:aws:states:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.name_prefix}-sales-pipeline"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "validator" {
  function_name    = "${var.name_prefix}-validate-sales-file"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = "validate_sales_file.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      SFN_ARN   = "arn:aws:states:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.name_prefix}-sales-pipeline"
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

resource "aws_s3_bucket_notification" "raw_uploads" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.validator.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_sns_topic" "pipeline" {
  name = "${var.name_prefix}-analytics-notifications"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.pipeline.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}

resource "aws_iam_role" "stepfunctions" {
  name = "${var.name_prefix}-analytics-stepfunctions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "stepfunctions" {
  name = "${var.name_prefix}-analytics-stepfunctions-policy"
  role = aws_iam_role.stepfunctions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "sns:Publish",
          "elasticmapreduce:AddJobFlowSteps",
          "elasticmapreduce:DescribeCluster"
        ]
        Resource = [

          aws_sns_topic.pipeline.arn,
          "*"
        ]
      }
    ]
  })
}

resource "aws_sfn_state_machine" "pipeline" {
  name     = "${var.name_prefix}-sales-pipeline"
  role_arn = aws_iam_role.stepfunctions.arn
  type     = "STANDARD"

  definition = templatefile("${path.module}/templates/sales_pipeline.json.tftpl", {
    emr_cluster_id = aws_emr_cluster.this.id
    script_bucket  = aws_s3_bucket.raw.bucket
    script_key     = aws_s3_object.spark_script.key
    raw_bucket     = aws_s3_bucket.raw.bucket
    curated_bucket = aws_s3_bucket.curated.bucket
    sns_topic_arn  = aws_sns_topic.pipeline.arn
    aws_region     = var.aws_region
  })
}

resource "aws_security_group" "emr_master" {
  name        = "${var.name_prefix}-emr-master"
  description = "Security group for the EMR master node"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "emr_slave" {
  name        = "${var.name_prefix}-emr-slave"
  description = "Security group for the EMR slave nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "emr_service" {
  name = "${var.name_prefix}-emr-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "elasticmapreduce.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "emr_service" {
  role       = aws_iam_role.emr_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role" "emr_ec2" {
  name = "${var.name_prefix}-emr-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "emr_ec2" {
  role       = aws_iam_role.emr_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_role_policy" "emr_s3_access" {
  name = "${var.name_prefix}-emr-s3-access"
  role = aws_iam_role.emr_ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw.arn,
          "${aws_s3_bucket.raw.arn}/*",
          aws_s3_bucket.curated.arn,
          "${aws_s3_bucket.curated.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "emr_ec2" {
  name = "${var.name_prefix}-emr-ec2-profile"
  role = aws_iam_role.emr_ec2.name
}

resource "aws_emr_cluster" "this" {
  name          = "${var.name_prefix}-sales-etl"
  release_label = "emr-6.15.0"
  applications  = ["Spark"]
  log_uri       = "s3://${aws_s3_bucket.raw.bucket}/logs/"

  service_role = aws_iam_role.emr_service.arn

  master_instance_group {
    instance_type  = var.emr_master_instance_type
    instance_count = 1
  }

  core_instance_group {
    instance_type  = var.emr_core_instance_type
    instance_count = var.emr_core_instance_count
  }

  ec2_attributes {
    subnet_id                         = var.subnet_ids[0]
    instance_profile                  = aws_iam_instance_profile.emr_ec2.arn
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
  }

  # Keep the cluster alive after creation so Step Functions can add steps
  keep_job_flow_alive_when_no_steps = true
  termination_protection            = false
}
