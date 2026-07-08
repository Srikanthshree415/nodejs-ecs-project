resource "aws_iam_role" "emr_service_role" {
  name = var.service_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "emr_service_policy" {
  name = "${var.service_role_name}-policy"
  role = aws_iam_role.emr_service_role.id

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
          var.raw_bucket_arn,
          "${var.raw_bucket_arn}/*",
          var.curated_bucket_arn,
          "${var.curated_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_emr_cluster" "this" {
  name          = var.cluster_name
  release_label = "emr-6.15.0"
  applications  = ["Spark"]
  service_role  = aws_iam_role.emr_service_role.arn

  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = var.master_security_group_id
    emr_managed_slave_security_group  = var.slave_security_group_id
    instance_profile                  = var.instance_profile_arn
  }

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 1
  }
}
