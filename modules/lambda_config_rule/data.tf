# Assume role policy for Lambda and Config
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "config.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = concat(
      var.additional_permissions,
      ["config:PutEvaluations", "config:GetComplianceDetailsByConfigRule", "config:GetResourceConfigHistory", "config:ListDiscoveredResources", "sts:AssumeRole"]
    )
    resources = ["*"]
  }
}

