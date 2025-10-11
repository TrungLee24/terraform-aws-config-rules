# AWS Config Rule
resource "aws_config_config_rule" "rule" {
  name = var.config_rule_parameters.name

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.config_rule_lambda.arn
    source_detail {
      event_source = "aws.config"
      message_type = "ConfigurationItemChangeNotification"
    }
    source_detail {
      event_source = "aws.config"
      message_type = "ScheduledNotification"
    }
  }

  dynamic "scope" {
    for_each = var.config_rule_parameters.resource_types != null ? [1] : []
    content {
      compliance_resource_types = var.config_rule_parameters.resource_types
    }
  }

  input_parameters = jsonencode(var.config_rule_parameters.input_parameters)

  depends_on = [aws_lambda_permission.allow_config]
}