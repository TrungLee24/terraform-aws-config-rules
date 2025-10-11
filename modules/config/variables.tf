variable "bucket_name" {
  description = "Name of the S3 bucket for AWS Config"
  type        = string
}

variable "config_role_arn" {
  description = "ARN of the IAM role for AWS Config"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications"
  type        = string
}

variable "recorder_name" {
  description = "Name of the AWS Config configuration recorder"
  type        = string
  default     = "config-recorder"
}

variable "delivery_channel_name" {
  description = "Name of the AWS Config delivery channel"
  type        = string
  default     = "config-delivery-channel"
}