# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-log-group"
  })
}

# CloudWatch Log Group for ALB
resource "aws_cloudwatch_log_group" "alb_log_group" {
  name              = "/alb/${var.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-log-group"
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "app_dashboard" {
  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.name_prefix}-service"],
            [".", "MemoryUtilization", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = var.alb_arn_suffix != "" ? [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ] : []
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Metrics"
          period  = 300
        }
      }
    ]
  })
}

# CloudWatch Alarms for ECS
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.name_prefix}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ServiceName = "${var.name_prefix}-service"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-cpu-high-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.name_prefix}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "This metric monitors ECS memory utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ServiceName = "${var.name_prefix}-service"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-memory-high-alarm"
  })
}

# CloudWatch Log Stream for application logs
resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "${var.name_prefix}-app-stream"
  log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
}
