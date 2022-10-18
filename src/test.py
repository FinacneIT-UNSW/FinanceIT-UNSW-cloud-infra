from src.aws.databases.dynamodb import AWSDynamoTable, AWSDynamoSchema, AWSDynamoAttributeType, AWSDynamoStreamType
from src.aws.api.rest import AWSAPILambdasIntegration, AWSRestApi
from src.aws.lambdas import AWSLambdasRuntime
from src.aws.aws import AWSProject

db = AWSDynamoTable(
    'TEST',
    5,
    5,
    AWSDynamoSchema('DeviceID', AWSDynamoAttributeType.STRING, 'Timestamp', AWSDynamoAttributeType.NUMBER),
    
)

api = AWSRestApi(
    'data',
    'v1',
    AWSAPILambdasIntegration(
        './lambdas_archives/point_query.zip',
        'point_query.lambda_handler',
        AWSLambdasRuntime.PY39,
    ),
    AWSAPILambdasIntegration(
        './lambdas_archives/point_put.zip',
        'point_put.lambda_handler',
        AWSLambdasRuntime.PY39,
    )
)

with open("test.tfvars", 'w+') as f:
    f.writelines(db.conf_lines())
    f.writelines(api.conf_lines())