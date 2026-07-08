resource "aws_iam_role" "states" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "states" {
  name = "${var.role_name}-policy"
  role = aws_iam_role.states.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = var.lambda_function_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_sfn_state_machine" "this" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.states.arn
  definition = jsonencode({
    Comment = "Orchestrate sales validation and EMR processing"
    StartAt = "ValidateFile"
    States = {
      ValidateFile = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.lambda_function_name
          Payload = {
            Records = "${var.event_payload_placeholder}" 
          }
        }
        End = true
      }
    }
  })
}
