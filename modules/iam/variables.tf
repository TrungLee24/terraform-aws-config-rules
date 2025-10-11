variable "role_name" {
  description = "Name of the IAM role for AWS Config"
  type        = string
  default     = "AWSConfigRole"
}

variable "s3_policy_name" {
  description = "Name of the IAM policy for S3 access"
  type        = string
  default     = "AWSConfigS3Policy"
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config"
  type        = string
}