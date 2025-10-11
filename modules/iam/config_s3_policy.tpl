{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "${bucket_arn}/AWSLogs/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetBucketAcl",
      "Resource": "${bucket_arn}"
    }
  ]
}