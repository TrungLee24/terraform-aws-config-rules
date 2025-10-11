
locals {
  rule_directories = ["s3", "iam", "ec2", "rds", "lambda"]

  rule_files = flatten([
    for dir in local.rule_directories : [
      for file in try(fileset("rules/${dir}", "*.py"), []) : {
        dir  = dir
        file = file
        name = trimsuffix(file, ".py")
      }
    ]
  ])

  permission_map = {
    "s3-s3_rdk" = [
      "s3:GetBucketEncryption",
      "s3:ListAllMyBuckets",
      "s3:GetEncryptionConfiguration"
    ]
    "s3-s3_boto3" = [
      "s3:GetBucketEncryption",
      "s3:ListAllMyBuckets",
      "s3:GetEncryptionConfiguration"
    ]
  }

  resource_type_map = {
    "s3-s3_rdk"   = ["AWS::S3::Bucket"]
    "s3-s3_boto3" = ["AWS::S3::Bucket"]
  }

  input_parameters_map = {
    "s3-s3_rdk" = {
      "AssumeRoleMode" = "False"
    }
  }

  dynamic_rules = {
    for rule in local.rule_files : "${rule.dir}-${rule.name}" => {
      lambda_role = "${rule.dir}-${rule.name}-role"

      lambda_parameters = {
        source_dir           = "rules/${rule.dir}"
        function_name        = "${rule.dir}-${rule.name}"
        function_description = "AWS Config rule for ${rule.dir} - ${rule.name}"
        handler              = "${rule.name}.handler"
        lambda_layer_arn     = endswith(rule.name, "_rdk") ? module.rdklib_layer.rdklib_layer_arn : null
      }

      additional_permissions = lookup(local.permission_map, "${rule.dir}-${rule.name}", [])

      config_rule_parameters = {
        name             = "${rule.dir}-${rule.name}-check"
        input_parameters = lookup(local.input_parameters_map, "${rule.dir}-${rule.name}", {})
        resource_types   = lookup(local.resource_type_map, "${rule.dir}-${rule.name}", null)
      }
    }
  }
}