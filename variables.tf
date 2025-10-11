variable "rules" {
  description = "List of Lambda + Config rule definitions (optional - rules are auto-discovered from rules/ directory)"
  type = list(object({
    lambda_role = string
    lambda_parameters = object({
      source_dir           = optional(string)
      filename             = optional(string)
      function_name        = string
      function_description = string
      handler              = string
      lambda_layer_arn     = optional(string)
    })
    additional_permissions = list(string)
    config_rule_parameters = object({
      name             = string
      input_parameters = optional(map(string))
      resource_types   = optional(list(string))
    })
  }))
  default = []
}

variable "lambda_compatible_runtimes" {
  description = "List of compatible runtimes for the Lambda layer"
  type        = list(string)
}

variable "layer_name" {
  description = "Name of the Lambda layer"
  type        = string
}

variable "region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for AWS Config"
  type        = string
}

variable "config_role_name" {
  description = "Name of the IAM role for AWS Config"
  type        = string
}

variable "s3_policy_name" {
  description = "Name of the IAM policy for S3 access"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for AWS Config notifications"
  type        = string
}

variable "sns_email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = string
}

variable "recorder_name" {
  description = "Name of the AWS Config configuration recorder"
  type        = string
}

variable "delivery_channel_name" {
  description = "Name of the AWS Config delivery channel"
  type        = string
}