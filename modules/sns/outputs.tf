output "sns_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config_topic.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config_topic.name
}