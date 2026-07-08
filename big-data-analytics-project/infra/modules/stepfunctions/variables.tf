variable "role_name" {
  description = "IAM role name for Step Functions"
  type        = string
}

variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function invoked by the state machine"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic used for notifications"
  type        = string
}

variable "event_payload_placeholder" {
  description = "Placeholder used in the state machine definition"
  type        = string
  default     = "$.Records"
}
