variable "lambda_role" {
  type = string
}

variable "lambda_parameters" {
  description = "Lambda function parameters"
  type = object({
    source_dir           = optional(string)
    filename             = optional(string)
    function_name        = string
    function_description = string
    handler              = string
    lambda_layer_arn     = optional(string)
  })
}

variable "additional_permissions" {
  type = list(string)
}

variable "config_rule_parameters" {
  description = "AWS Config rule parameters"
  type = object({
    name             = string
    input_parameters = optional(map(string), {})
    resource_types   = optional(list(string))
  })
}