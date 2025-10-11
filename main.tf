provider "aws" {
  region = var.region
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.bucket_name
}

module "iam" {
  source = "./modules/iam"

  bucket_arn     = module.s3.bucket_arn
  role_name      = var.config_role_name
  s3_policy_name = var.s3_policy_name
}

module "config" {
  source = "./modules/config"

  bucket_name           = module.s3.bucket_name
  config_role_arn       = module.iam.config_role_arn
  sns_topic_arn         = module.sns.sns_topic_arn
  recorder_name         = var.recorder_name
  delivery_channel_name = var.delivery_channel_name
}

module "sns" {
  source = "./modules/sns"

  sns_topic_name  = var.sns_topic_name
  email_addresses = var.sns_email_addresses
}

module "rdklib_layer" {
  source = "./modules/rdklib_layer"

  layer_name                 = var.layer_name
  lambda_compatible_runtimes = var.lambda_compatible_runtimes
}

module "rules" {
  for_each = local.dynamic_rules

  source                 = "./modules/lambda_config_rule"
  lambda_role            = each.value.lambda_role
  lambda_parameters      = each.value.lambda_parameters
  config_rule_parameters = each.value.config_rule_parameters
  additional_permissions = each.value.additional_permissions

  depends_on = [module.rdklib_layer]
}

# Static rules from terraform.tfvars (commented out)
# module "static_rules" {
#   for_each = { for idx, rule in var.rules : idx => rule }
# 
#   source                 = "./modules/lambda_config_rule"
#   lambda_role            = each.value.lambda_role
#   lambda_parameters      = each.value.lambda_parameters
#   config_rule_parameters = each.value.config_rule_parameters
#   additional_permissions = each.value.additional_permissions
# }

