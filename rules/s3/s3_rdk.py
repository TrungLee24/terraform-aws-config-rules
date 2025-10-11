import json
import logging
import datetime
from rdklib import ConfigRule, Evaluator, Evaluation, ComplianceType
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def convert_datetime(obj):
    if isinstance(obj, datetime.datetime):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} not serializable")

class S3KmsEncryptionCheck(ConfigRule):

    def evaluate_change(self, event, client_factory, configuration_item, valid_rule_parameters):
        bucket_name = configuration_item["resourceName"]
        logger.info(f"Change-triggered evaluation for S3 bucket: {bucket_name}")
        return [self._evaluate_bucket(client_factory, bucket_name)]

    def evaluate_periodic(self, event, client_factory, valid_rule_parameters):
        logger.info("Starting periodic evaluation for all S3 buckets")
        s3 = client_factory.build_client("s3")
        evaluations = []
        for bucket in s3.list_buckets()["Buckets"]:
            bucket_name = bucket["Name"]
            evaluations.append(self._evaluate_bucket(client_factory, bucket_name))
        logger.info(f"Completed periodic evaluation, total buckets evaluated: {len(evaluations)}")
        return evaluations

    def _evaluate_bucket(self, client_factory, bucket_name):
        s3 = client_factory.build_client("s3")
        try:
            enc = s3.get_bucket_encryption(Bucket=bucket_name)
            rules = enc["ServerSideEncryptionConfiguration"]["Rules"]
            for rule in rules:
                algo = rule["ApplyServerSideEncryptionByDefault"]["SSEAlgorithm"]
                if algo == "aws:kms":
                    return Evaluation(
                        resourceId=bucket_name,
                        resourceType="AWS::S3::Bucket",
                        complianceType=ComplianceType.COMPLIANT,
                        annotation="S3 bucket is encrypted with AWS KMS."
                    )
            return Evaluation(
                resourceId=bucket_name,
                resourceType="AWS::S3::Bucket",
                complianceType=ComplianceType.NON_COMPLIANT,
                annotation="S3 bucket encryption found but not using KMS."
            )
        except ClientError as e:
            if e.response["Error"]["Code"] == "ServerSideEncryptionConfigurationNotFoundError":
                return Evaluation(
                    resourceId=bucket_name,
                    resourceType="AWS::S3::Bucket",
                    complianceType=ComplianceType.NON_COMPLIANT,
                    annotation="No default encryption configured."
                )
            raise e

def handler(event, context):
    logger.info(f"Lambda invoked with event: {json.dumps(event, default=convert_datetime)}")
    rule = S3KmsEncryptionCheck()
    evaluator = Evaluator(rule, ["AWS::S3::Bucket"])
    return evaluator.handle(event, context)