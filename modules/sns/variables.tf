variable "sns_topic_name" {
  description = "Name of the SNS topic for AWS Config notifications"
  type        = string
  default     = "aws-config-notifications"
}

variable "email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = string
}