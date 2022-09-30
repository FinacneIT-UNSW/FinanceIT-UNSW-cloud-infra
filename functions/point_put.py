import logging
import boto3
import json
import os


logger = logging.getLogger()
logger.setLevel(logging.INFO)

session = boto3.Session(region_name=os.environ['REGION'])
dynamodb_client = session.client('dynamodb')

ATTRIBUTES = ['DeviceID', 'Timestamp', 'Temperature', 'Co2', 'VOC', 'Humidity', 'PM25', 'PM10']

def lambda_handler(event, context):

    try:
        payload = json.loads(event["body"])

        if not all(key in payload.keys() for key in ATTRIBUTES):
            return {
                'statusCode': 400,
                'body': '{"status":"Missing attributes for insertion"}',
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

        dynamodb_response = dynamodb_client.put_item(
            TableName=os.environ["DYNAMO_TABLE"],
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
        logger.info(dynamodb_response)
        return {
            'statusCode': 200,
            'body': 'successfully created item!',
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    except Exception as e:
        logger.error(e)
        return {
            'statusCode': 500,
            'body': '{"status":"Server error"}',
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }