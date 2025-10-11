output "bucket_name" {
  description = "Name of the S3 bucket created for AWS Config"
  value       = aws_s3_bucket.config_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket created for AWS Config"
  value       = aws_s3_bucket.config_bucket.arn
}