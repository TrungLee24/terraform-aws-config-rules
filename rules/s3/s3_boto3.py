import json
import boto3
import logging
from datetime import datetime, timezone
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

config = boto3.client("config")
s3 = boto3.client("s3")

def evaluate_bucket(bucket_name):
    try:
        enc = s3.get_bucket_encryption(Bucket=bucket_name)
        rules = enc["ServerSideEncryptionConfiguration"]["Rules"]
        for rule in rules:
            algo = rule["ApplyServerSideEncryptionByDefault"]["SSEAlgorithm"]
            if algo == "aws:kms":
                logger.info(f"COMPLIANT: Bucket {bucket_name} encrypted with KMS")
                return "COMPLIANT", "S3 bucket is encrypted with AWS KMS."
        logger.warning(f"NON_COMPLIANT: Bucket {bucket_name} uses encryption but not KMS")
        return "NON_COMPLIANT", "S3 bucket encryption found but not using KMS."

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "ServerSideEncryptionConfigurationNotFoundError":
            logger.warning(f"NON_COMPLIANT: Bucket {bucket_name} has no default encryption")
            return "NON_COMPLIANT", "S3 bucket has no default encryption."
        elif error_code == "AccessDenied":
            logger.warning(f"NOT_APPLICABLE: Access denied for bucket {bucket_name}")
            return "NOT_APPLICABLE", "Access denied when checking encryption configuration."
        else:
            logger.error(f"Unexpected error for {bucket_name}: {str(e)}")
            return "NOT_APPLICABLE", f"Unexpected error: {str(e)}"

def handler(event, context):
    logger.info(f"Lambda invoked with event: {json.dumps(event)}")

    invoking_event = json.loads(event["invokingEvent"])
    message_type = invoking_event.get("messageType")
    result_token = event.get("resultToken", "NoTokenProvided")
    evaluations = []

    if message_type == "ConfigurationItemChangeNotification":
        config_item = invoking_event["configurationItem"]
        resource_type = config_item["resourceType"]
        resource_id = config_item["resourceId"]
        bucket_name = config_item["resourceName"]

        logger.info(f"Evaluating configuration change for bucket: {bucket_name}")
        compliance_type, annotation = evaluate_bucket(bucket_name)

        evaluations.append({
            "ComplianceResourceType": resource_type,
            "ComplianceResourceId": resource_id,
            "ComplianceType": compliance_type,
            "Annotation": annotation,
            "OrderingTimestamp": datetime.now(timezone.utc)
        })

    elif message_type == "ScheduledNotification":
        logger.info("Starting periodic evaluation for all S3 buckets")
        buckets = s3.list_buckets().get("Buckets", [])
        for b in buckets:
            bucket_name = b["Name"]
            compliance_type, annotation = evaluate_bucket(bucket_name)
            evaluations.append({
                "ComplianceResourceType": "AWS::S3::Bucket",
                "ComplianceResourceId": bucket_name,
                "ComplianceType": compliance_type,
                "Annotation": annotation,
                "OrderingTimestamp": datetime.now(timezone.utc)
            })
        logger.info(f"Periodic evaluation complete: {len(evaluations)} buckets checked")

    else:
        logger.warning(f"Unsupported message type: {message_type}")
        return {"error": f"Unsupported message type: {message_type}"}

    if evaluations:
        logger.info(f"Submitting {len(evaluations)} evaluations to AWS Config")
        try:
            config.put_evaluations(
                Evaluations=evaluations,
                ResultToken=result_token
            )
        except ClientError as e:
            logger.error(f"Error submitting evaluations: {str(e)}")

    return {"status": "OK", "evaluations_submitted": len(evaluations)}