variable "topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "email_endpoint" {
  description = "Email address to subscribe to SNS notifications"
  type        = string
}
