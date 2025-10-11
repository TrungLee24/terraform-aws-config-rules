output "config_role_arn" {
  description = "ARN of the IAM role for AWS Config"
  value       = aws_iam_role.config_role.arn
}

output "config_role_name" {
  description = "Name of the IAM role for AWS Config"
  value       = aws_iam_role.config_role.name
}