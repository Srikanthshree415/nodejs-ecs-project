# Infrastructure deployment

This folder contains Terraform code for creating the foundational AWS resources for the analytics pipeline.

## Resources created
- Amazon S3 raw bucket
- Amazon S3 curated bucket
- AWS Lambda function for CSV validation
- Amazon SNS topic
- IAM role for Lambda

## Deployment steps
1. Change the bucket names in terraform.tfvars if needed.
2. Run `terraform init`.
3. Run `terraform plan`.
4. Run `terraform apply`.

## Important note
Before applying, package the Lambda code into a zip file.
