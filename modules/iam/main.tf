# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-task-execution-role"
  })
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for CloudWatch Logs
resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "${var.name_prefix}-ecs-cloudwatch-logs-policy"
  description = "Policy for ECS tasks to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/ecs/${var.name_prefix}*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-cloudwatch-logs-policy"
  })
}

# Attach custom CloudWatch Logs policy to execution role
resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
}

# ECS Task Role (for application-level permissions)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-task-role"
  })
}

# Custom policy for ECS task role (application permissions)
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${var.name_prefix}-ecs-task-policy"
  description = "Policy for ECS tasks application permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.name_prefix}-*/*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-task-policy"
  })
}

# Attach custom policy to task role
resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}