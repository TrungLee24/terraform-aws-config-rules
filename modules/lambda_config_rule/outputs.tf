output "lambda_name" {
  description = "The name of the AWS Lambda function"
  value       = aws_lambda_function.config_rule_lambda.function_name
}

output "lambda_arn" {
  description = "The ARN of the AWS Lambda function"
  value       = aws_lambda_function.config_rule_lambda.arn
}
