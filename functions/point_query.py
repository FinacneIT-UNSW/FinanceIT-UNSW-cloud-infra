import logging
import boto3
import json
import os


logger = logging.getLogger()
logger.setLevel(logging.INFO)

session = boto3.Session(region_name=os.environ.get('REGION', 'ap-southeast-2'))
dynamodb_client = session.client('dynamodb')

def lambda_handler(event, context):

    try:
        logger.info(event)
        payload = json.loads(event["body"])

        fromts = payload.get('from', 0)
        tots = payload['to']

        dynamodb_response = dynamodb_client.query(
            TableName = os.environ["DYNAMO_TABLE"],
            KeyConditionExpression = f'DeviceID = :di AND #T BETWEEN :start AND :end',
            ExpressionAttributeValues = {
                ':di': {'S': '000-000'},
                ':end': {'N': tots},
                ':start': {'N': fromts}
            },
            ExpressionAttributeNames = {
                '#T': 'Timestamp'
            }
        )

        # logger.info(dynamodb_response)
        return {
            'statusCode': 200,
            'body': json.dumps(dynamodb_response['Items']),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    except Exception as e:
        logger.error(e)
        return {
            'statusCode': 500,
            'body': '{"status": "Server error"}',
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
