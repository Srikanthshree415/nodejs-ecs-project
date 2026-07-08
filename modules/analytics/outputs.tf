output "raw_bucket_name" {
  value = aws_s3_bucket.raw.bucket
}

output "curated_bucket_name" {
  value = aws_s3_bucket.curated.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.validator.function_name
}

output "step_function_arn" {
  value = aws_sfn_state_machine.pipeline.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.pipeline.arn
}

output "emr_cluster_id" {
  value = aws_emr_cluster.this.id
}
