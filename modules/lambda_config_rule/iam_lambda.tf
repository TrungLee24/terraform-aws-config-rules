# IAM Role
resource "aws_iam_role" "lambda_exec" {
  name               = var.lambda_role
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

# IAM Policy
resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.lambda_role}-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# Role Policy Attachment
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}