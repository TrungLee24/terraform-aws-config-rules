resource "aws_lambda_layer_version" "rdklib" {
  filename            = "${path.module}/rdklib-layer.zip"
  layer_name          = var.layer_name
  compatible_runtimes = var.lambda_compatible_runtimes
  source_code_hash    = filebase64sha256("${path.module}/rdklib-layer.zip")
  description         = "RDKLib for AWS Config Custom Lambda Rules"
}