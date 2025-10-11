resource "aws_sns_topic" "config_topic" {
  name = var.sns_topic_name

  tags = {
    Name        = "YTAWSConfigTopic"
    Environment = "Training"
  }
}

resource "aws_sns_topic_subscription" "email_subscriptions" {

  topic_arn = aws_sns_topic.config_topic.arn
  protocol  = "email"
  endpoint  = var.email_addresses
}