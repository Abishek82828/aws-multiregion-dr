import decimal
import json
import os
import time
import uuid

import boto3

TABLE_NAME = os.environ["TABLE_NAME"]
REGION = os.environ["AWS_REGION"]

table = boto3.resource("dynamodb").Table(TABLE_NAME)


class _DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            return int(o)
        return super().default(o)


def _response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, cls=_DecimalEncoder),
    }


def handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method", "GET")
    path = event.get("rawPath", "/")

    if path == "/health":
        return _response(200, {"status": "ok", "region": REGION})

    if method == "GET" and path == "/items":
        items = table.scan().get("Items", [])
        return _response(200, {"region": REGION, "items": items})

    if method == "POST" and path == "/items":
        body = json.loads(event.get("body") or "{}")
        item = {
            "id": str(uuid.uuid4()),
            "text": body.get("text", ""),
            "created_at": int(time.time()),
            "written_by_region": REGION,
        }
        table.put_item(Item=item)
        return _response(201, item)

    return _response(404, {"error": "not found"})
