output "s3_bucket_name" {
  description = "Name of the S3 bucket used for AWS Config"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used for AWS Config"
  value       = module.s3.bucket_arn
}

output "config_role_arn" {
  description = "ARN of the IAM role used for AWS Config"
  value       = module.iam.config_role_arn
}

output "config_role_name" {
  description = "Name of the IAM role used for AWS Config"
  value       = module.iam.config_role_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for AWS Config notifications"
  value       = module.sns.sns_topic_arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic used for AWS Config notifications"
  value       = module.sns.sns_topic_name
}

output "config_recorder_name" {
  description = "Name of the AWS Config configuration recorder"
  value       = module.config.recorder_name
}

output "config_delivery_channel_name" {
  description = "Name of the AWS Config delivery channel"
  value       = module.config.delivery_channel_name
}

output "rdklib_layer_arn" {
  description = "ARN of the RDKLib Lambda layer"
  value       = module.rdklib_layer.rdklib_layer_arn
}