# AWS Config Rules with Terraform

[![AWS Config](https://img.shields.io/badge/AWS-Config-orange?logo=amazon-aws&logoColor=white)](https://docs.aws.amazon.com/config/latest/developerguide/)
[![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-purple?logo=terraform&logoColor=white)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python&logoColor=white)](https://www.python.org/)
[![Lambda](https://img.shields.io/badge/AWS-Lambda-orange?logo=aws-lambda&logoColor=white)](https://docs.aws.amazon.com/lambda/latest/dg/)
[![RDKLib](https://img.shields.io/badge/RDKLib-Framework-green?logo=github&logoColor=white)](https://github.com/awslabs/aws-config-rdklib)
[![Boto3](https://img.shields.io/badge/Boto3-SDK-yellow?logo=amazon-aws&logoColor=white)](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)

This Terraform configuration provides a complete AWS Config setup with dynamic Lambda-based custom rules. It automatically discovers Python rule files and creates the necessary AWS resources for compliance monitoring.

## Architecture Overview

The solution creates:
- **AWS Config**: Configuration recorder and delivery channel
- **S3 Bucket**: Stores configuration snapshots and history
- **SNS Topic**: Sends compliance notifications
- **Lambda Functions**: Custom Config rules (both RDK and Boto3 based)
- **Lambda Layer**: RDKLib dependencies for RDK-based rules
- **IAM Roles**: Proper permissions for all components

## Project Structure

```
├── modules/
│   ├── config/           # AWS Config setup
│   ├── iam/              # IAM roles and policies
│   ├── lambda_config_rule/ # Lambda function module
│   ├── rdklib_layer/     # Lambda layer with RDK dependencies
│   ├── s3/               # S3 bucket for Config
│   └── sns/              # SNS notifications
├── rules/
│   └── s3/               # Rule files organized by service
│       ├── s3_rdk.py     # RDK-based rule
│       └── s3_boto3.py   # Boto3-based rule
├── temp/                 # Generated zip files
├── locals.tf             # Dynamic rule discovery
├── main.tf               # Main configuration
├── variables.tf          # Input variables
├── terraform.tfvars     # Variable values
└── outputs.tf            # Output values
```

## Rule Types Supported

### 1. RDK-Based Rules (`*_rdk.py`)
- **Framework**: Uses the RDKLib framework for AWS Config rule development
- **Layer**: Automatically gets the RDKLib Lambda layer with all dependencies
- **Configuration**: Requires `AssumeRoleMode = "False"` parameter
- **Structure**: Provides standardized class-based approach with built-in evaluation methods
- **Error Handling**: Built-in exception handling and logging
- **Example**: `s3_rdk.py`

**When to use RDK:**
- ✅ **Complex rules** with multiple evaluation scenarios
- ✅ **Standardized development** following AWS best practices
- ✅ **Built-in testing framework** with RDKLib test utilities
- ✅ **Consistent error handling** and logging patterns
- ✅ **Future-proof** - maintained by AWS Labs
- ✅ **Rich evaluation context** with client factory pattern
- ✅ **Automatic compliance type handling**

### 2. Boto3-Based Rules (`*_boto3.py`)
- **Framework**: Uses native boto3 SDK directly
- **Layer**: No additional layer required (boto3 included in Lambda runtime)
- **Configuration**: Direct AWS API calls with manual error handling
- **Structure**: Simple function-based approach
- **Flexibility**: Full control over AWS service interactions
- **Example**: `s3_boto3.py`

**When to use Boto3:**
- ✅ **Simple rules** with straightforward logic
- ✅ **Minimal dependencies** - no external layers needed
- ✅ **Custom AWS service interactions** not covered by RDKLib
- ✅ **Performance-critical** rules (no framework overhead)
- ✅ **Legacy compatibility** with existing boto3 code
- ✅ **Fine-grained control** over AWS API calls
- ✅ **Smaller deployment package** size

### Comparison Matrix

| Feature | RDK-Based | Boto3-Based |
|---------|-----------|-------------|
| **Learning Curve** | Moderate | Low |
| **Development Speed** | Fast (after setup) | Fast (immediate) |
| **Code Structure** | Standardized | Flexible |
| **Error Handling** | Built-in | Manual |
| **Testing** | Framework provided | Custom |
| **Dependencies** | RDKLib layer | None |
| **Package Size** | Larger | Smaller |
| **AWS Best Practices** | Enforced | Manual |
| **Maintenance** | Framework updates | Self-maintained |

## Quick Start

### 1. Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- Python 3.12 (for local testing)

### 2. Configuration
Update `terraform.tfvars`:
```hcl
region                     = "eu-west-2"
bucket_name                = "your-config-bucket"
sns_email_addresses        = "your-email@domain.com"
# ... other variables
```

### 3. Deploy
```bash
terraform init
terraform plan
terraform apply
```

## Adding New Rules

### 1. Create Rule Directory
```bash
mkdir rules/ec2
```

### 2. Add Rule Files
Create Python files following naming convention:
- `ec2_instance_check_rdk.py` (for RDK-based rules)
- `ec2_instance_check_boto3.py` (for Boto3-based rules)

### 3. Update Configuration
Add the new service to `locals.tf`:
```hcl
rule_directories = ["s3", "iam", "ec2", "rds", "lambda"]
```

### 4. Configure Permissions (if needed)
Add required permissions to `permission_map` in `locals.tf`:
```hcl
permission_map = {
  "ec2-ec2_instance_check_rdk" = [
    "ec2:DescribeInstances",
    "ec2:DescribeInstanceAttribute"
  ]
}
```

### 5. Set Resource Types
Add resource types to `resource_type_map`:
```hcl
resource_type_map = {
  "ec2-ec2_instance_check_rdk" = ["AWS::EC2::Instance"]
}
```

### 6. Apply Changes
```bash
terraform plan
terraform apply
```

## Rule Development Guidelines

### RDK Rule Template
```python
import json
import logging
from rdklib import ConfigRule, Evaluator, Evaluation, ComplianceType

class YourRuleClass(ConfigRule):
    def evaluate_change(self, event, client_factory, configuration_item, valid_rule_parameters):
        # Handle configuration changes
        pass
    
    def evaluate_periodic(self, event, client_factory, valid_rule_parameters):
        # Handle periodic evaluations
        pass

def handler(event, context):
    rule = YourRuleClass()
    evaluator = Evaluator(rule, ["AWS::ResourceType"])
    return evaluator.handle(event, context)
```

### Boto3 Rule Template
```python
import json
import boto3
import logging
from datetime import datetime

def handler(event, context):
    config = boto3.client("config")
    # Your evaluation logic here
    
    evaluations = []
    # Build evaluations list
    
    config.put_evaluations(
        Evaluations=evaluations,
        ResultToken=event["resultToken"]
    )
    return {"evaluations": evaluations}
```

## Production Considerations

### 1. Security
- Use least privilege IAM policies
- Enable S3 bucket encryption
- Configure VPC endpoints for private communication
- Review and audit rule permissions regularly

### 2. Cost Optimization
- Set appropriate CloudWatch log retention (currently 14 days)
- Monitor Lambda execution costs
- Use Config rule scopes to limit evaluations
- Consider using Config Organization rules for multi-account setups

### 3. Monitoring
- Set up CloudWatch alarms for Lambda errors
- Monitor Config compliance dashboards
- Configure SNS notifications for critical compliance failures
- Use AWS Config Insights for trend analysis

### 4. Scalability
- The solution automatically scales with new rules
- Lambda concurrency limits may need adjustment for large environments
- Consider Config aggregators for multi-region setups

### 5. Maintenance
- Regularly update RDKLib layer dependencies
- Test rules in development environment first
- Use version control for rule changes
- Document custom rule logic and requirements

## Troubleshooting

### Common Issues

1. **Lambda Import Errors**
   - Ensure RDK rules use `*_rdk.py` naming convention
   - Verify RDKLib layer is attached to RDK rules only

2. **Permission Denied**
   - Check IAM policies in `permission_map`
   - Verify Config service role permissions

3. **Rules Not Triggering**
   - Confirm resource types in `resource_type_map`
   - Check Config recorder is active

4. **Archive File Issues**
   - Ensure rule directories exist under `rules/`
   - Verify Python files have `.py` extension

### Debugging
- Check CloudWatch logs for Lambda functions
- Use AWS Config console to view rule evaluations
- Monitor SNS topic for compliance notifications

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Note**: This will delete all Config history and compliance data.

## Contributing

1. Follow the established naming conventions
2. Test rules thoroughly before deployment
3. Update documentation for new rule types
4. Ensure proper error handling in custom rules

## Reference Links

### Official Documentation
[![AWS Config Guide](https://img.shields.io/badge/AWS_Config-Developer_Guide-orange?logo=amazon-aws&logoColor=white)](https://docs.aws.amazon.com/config/latest/developerguide/)
[![Config Rules](https://img.shields.io/badge/AWS_Config-Rules_Guide-orange?logo=amazon-aws&logoColor=white)](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config.html)
[![Lambda Guide](https://img.shields.io/badge/AWS_Lambda-Developer_Guide-orange?logo=aws-lambda&logoColor=white)](https://docs.aws.amazon.com/lambda/latest/dg/)

### Development Frameworks
[![Boto3](https://img.shields.io/badge/Boto3-Documentation-yellow?logo=amazon-aws&logoColor=white)](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
[![RDK](https://img.shields.io/badge/AWS_Config-RDK-green?logo=github&logoColor=white)](https://github.com/awslabs/aws-config-rdk)
[![RDKLib](https://img.shields.io/badge/AWS_Config-RDKLib-green?logo=github&logoColor=white)](https://github.com/awslabs/aws-config-rdklib)
[![RDKLib Docs](https://img.shields.io/badge/RDKLib-Documentation-blue?logo=readthedocs&logoColor=white)](https://aws-config-rdklib.readthedocs.io/en/stable/)

### Sample Rules and Examples
[![Config Rules Repo](https://img.shields.io/badge/AWS_Config-Rules_Repository-green?logo=github&logoColor=white)](https://github.com/awslabs/aws-config-rules)
[![RDK Examples](https://img.shields.io/badge/Config_RDK-Examples-green?logo=github&logoColor=white)](https://github.com/awslabs/aws-config-rdk)

### Terraform Resources
[![Terraform AWS](https://img.shields.io/badge/Terraform-AWS_Provider-purple?logo=terraform&logoColor=white)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![Terraform Config](https://img.shields.io/badge/Terraform-AWS_Config-purple?logo=terraform&logoColor=white)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder)est/docs
- **Terraform AWS Config**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder

## License

This project is licensed under the MIT License - see the LICENSE file for details.