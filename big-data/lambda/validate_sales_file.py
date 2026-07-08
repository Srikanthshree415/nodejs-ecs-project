import csv
import io
import json
import logging

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

REQUIRED_COLUMNS = ["order_id", "order_date", "customer_id", "product_id", "quantity", "price"]


def lambda_handler(event, context):
    try:
        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        if not key.lower().endswith(".csv"):
            raise ValueError("Only CSV files are supported")

        s3 = boto3.client("s3")
        obj = s3.get_object(Bucket=bucket, Key=key)
        content = obj["Body"].read().decode("utf-8-sig")
        reader = csv.DictReader(io.StringIO(content))

        if reader.fieldnames is None:
            raise ValueError("CSV file is missing a header row")

        normalized = [name.strip().lower() for name in reader.fieldnames]
        missing = [col for col in REQUIRED_COLUMNS if col not in normalized]
        if missing:
            raise ValueError(f"Missing required columns: {missing}")

        rows = list(reader)
        if not rows:
            raise ValueError("CSV file is empty")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "validated": True,
                "bucket": bucket,
                "key": key,
                "row_count": len(rows)
            })
        }
    except Exception as exc:
        logger.exception("Validation failed")
        return {
            "statusCode": 400,
            "body": json.dumps({"validated": False, "error": str(exc)})
        }
