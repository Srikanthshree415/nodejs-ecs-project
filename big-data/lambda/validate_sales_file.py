import csv
import io
import json
import logging
import os
import urllib.parse

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

REQUIRED_COLUMNS = [
    "rank",
    "title",
    "genre",
    "description",
    "director",
    "actors",
    "year",
    "runtime_minutes",
    "rating",
    "votes",
    "revenue_millions",
    "metascore",
]


def normalize_header(name):
    return (
        name.strip()
        .lower()
        .replace(" ", "_")
        .replace("(", "")
        .replace(")", "")
    )


def get_s3_target(event):
    if isinstance(event, dict) and event.get("Records"):
        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        return bucket, key

    if isinstance(event, dict):
        bucket = event.get("bucket")
        key = event.get("key")
        if bucket and key:
            return bucket, key

    raise ValueError("Expected an S3 notification event with Records, or a manual test payload with bucket and key")


def lambda_handler(event, context):
    s3 = boto3.client("s3")
    sfn = boto3.client("stepfunctions")
    try:
        bucket, key = get_s3_target(event)
        key = urllib.parse.unquote(key).strip()
        if key.startswith("/"):
            key = key[1:]

        logger.info(f"Processing S3 event for bucket={bucket}, key={key}")
        logger.info(f"Processed key repr={repr(key)}")

        if not key.lower().endswith(".csv"):
            raise ValueError("Only CSV files are supported")

        obj = s3.get_object(Bucket=bucket, Key=key)
        content = obj["Body"].read().decode("utf-8-sig")
        reader = csv.DictReader(io.StringIO(content))

        if reader.fieldnames is None:
            raise ValueError("CSV file is missing a header row")

        normalized = [normalize_header(name) for name in reader.fieldnames]
        missing = [col for col in REQUIRED_COLUMNS if col not in normalized]
        if missing:
            raise ValueError(f"Missing required columns: {missing}")

        rows = list(reader)
        if not rows:
            raise ValueError("CSV file is empty")

        # Start Step Functions execution if configured
        sfn_arn = os.environ.get("SFN_ARN")
        started = False
        execution_arn = None
        if sfn_arn:
            try:
                payload = {"bucket": bucket, "key": key, "row_count": len(rows)}
                resp = sfn.start_execution(stateMachineArn=sfn_arn, input=json.dumps(payload))
                execution_arn = resp.get("executionArn")
                started = True
                logger.info(f"Started Step Functions execution: {execution_arn}")
            except Exception:
                logger.exception("Failed to start Step Functions execution")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "validated": True,
                "bucket": bucket,
                "key": key,
                "row_count": len(rows),
                "stepfunctions_started": started,
                "execution_arn": execution_arn,
            })
        }
    except Exception as exc:
        logger.exception("Validation failed")
        return {
            "statusCode": 400,
            "body": json.dumps({"validated": False, "error": str(exc)})
        }
