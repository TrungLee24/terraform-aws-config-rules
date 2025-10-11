variable "lambda_compatible_runtimes" {
  description = "List of compatible runtimes for the Lambda layer"
  type        = list(string)
}

variable "layer_name" {
  description = "Name of the Lambda layer"
  type        = string
}