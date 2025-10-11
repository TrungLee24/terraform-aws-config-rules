# Archive source code if source_dir is provided
data "archive_file" "lambda_zip" {
  # count       = var.lambda_parameters.source_dir != null ? 1 : 0
  type        = "zip"
  source_dir  = "${path.root}/${var.lambda_parameters.source_dir}"
  output_path = "${path.root}/temp/${var.lambda_parameters.function_name}.zip"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_parameters.function_name}-lambda"
  retention_in_days = 14
}

# Lambda Function
resource "aws_lambda_function" "config_rule_lambda" {
  filename      = var.lambda_parameters.source_dir != null ? data.archive_file.lambda_zip.output_path : var.lambda_parameters.filename
  description   = var.lambda_parameters.function_description
  function_name = var.lambda_parameters.function_name
  handler       = var.lambda_parameters.handler
  runtime       = "python3.12"
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.lambda_log_group.name
  }
  role             = aws_iam_role.lambda_exec.arn
  layers           = var.lambda_parameters.lambda_layer_arn != null ? [var.lambda_parameters.lambda_layer_arn] : null
  source_code_hash = var.lambda_parameters.source_dir != null ? data.archive_file.lambda_zip.output_base64sha256 : filebase64sha256(var.lambda_parameters.filename)
  timeout          = 60

  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
}

# Lambda Permission for Config
resource "aws_lambda_permission" "allow_config" {
  statement_id   = "AllowExecutionFromConfig"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.config_rule_lambda.function_name
  principal      = "config.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}