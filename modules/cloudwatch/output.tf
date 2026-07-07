output "ecs_log_group_name" {
  description = "Name of the ECS CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_log_group.name
}

output "ecs_log_group_arn" {
  description = "ARN of the ECS CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_log_group.arn
}

output "alb_log_group_name" {
  description = "Name of the ALB CloudWatch log group"
  value       = aws_cloudwatch_log_group.alb_log_group.name
}

output "alb_log_group_arn" {
  description = "ARN of the ALB CloudWatch log group"
  value       = aws_cloudwatch_log_group.alb_log_group.arn
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.app_dashboard.dashboard_name}"
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
}

output "memory_alarm_arn" {
  description = "ARN of the memory alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_memory_high.arn
}
