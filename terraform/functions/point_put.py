import logging
import boto3
import traceback
import json
import os


LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

REGION = os.environ.get('REGION', 'ap-southeast-2')
session = boto3.Session(region_name=REGION)
dynamodb_client = session.client('dynamodb')

TABLE_NAME = os.environ["DYNAMO_TABLE"]
ATTRIBUTES = ['DeviceID', 'Timestamp', 'Temperature', 'Co2', 'VOC', 'Humidity', 'PM25', 'PM10']

def lambda_handler(event, context):

    try:
        LOGGER.info(f"Received event: {event}")
        payload = json.loads(event["body"])

        if not all(key in payload.keys() for key in ATTRIBUTES):
            LOGGER.info(f"Missing parameters in requests")
            return {
                'statusCode': 400,
                'body': '{"status":"Missing attributes for insertion"}',
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

        dynamodb_response = dynamodb_client.put_item(
            TableName=TABLE_NAME,
            Item={
                "DeviceID": {
                    "S": payload["DeviceID"]
                },
                "Timestamp": {
                    "N": payload["Timestamp"]
                },
                "Temperature": {
                    "N": payload["Temperature"]
                },
                "Co2": {
                    "N": payload["Co2"]
                },
                "VOC": {
                    "N": payload["VOC"]
                },
                "Humidity": {
                    "N": payload["Humidity"]
                },
                "PM25": {
                    "N": payload["PM25"]
                },
                "PM10": {
                    "N": payload["PM10"]
                }
            }
        )
        LOGGER.info(f"Item inserted")
        return {
            'statusCode': 200,
            'body': 'successfully created item!',
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    except Exception as e:
        LOGGER.error(f"Error inserting item: {e}")
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': '{"status":"Server error"}',
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }