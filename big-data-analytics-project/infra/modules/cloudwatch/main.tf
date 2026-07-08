resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${var.lambda_function_name}"
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.lambda_function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}
