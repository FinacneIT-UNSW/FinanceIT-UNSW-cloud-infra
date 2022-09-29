import logging
import boto3
import json
import os


logger = logging.getLogger()
logger.setLevel(logging.INFO)

session = boto3.Session(region_name=os.environ['REGION'])
dynamodb_client = session.client('dynamodb')

def lambda_handler(event, context):

    try:
        payload = json.loads(event["body"])
        logger.info("payload ->" + str(payload))

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
            'statusCode': 201,
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