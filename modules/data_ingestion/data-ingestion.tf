resource "aws_dynamodb_table" "indoor-air-test-dynamodb-table" {
  name           = "IndoorAirObservation${local.name_suffix}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "DeviceID"
  range_key      = "Timestamp"

  attribute {
    name = "DeviceID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  /* attribute {
    name = "Temperature"
    type = "N"
  }

  attribute {
    name = "Co2"
    type = "N"
  }

  attribute {
    name = "VOC"
    type = "N"
  }

  attribute {
    name = "Humidity"
    type = "N"
  }

  attribute {
    name = "PM25"
    type = "N"
  }

  attribute {
    name = "PM10"
    type = "N"
  } */

  tags = local.tags
}

data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "indoor-air-test-table-write-policy-doc" {
  statement {
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.indoor-air-test-dynamodb-table.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "indoor-air-test-table-write-policy" {
  name        = "IndoorAirObservation-Write${local.name_suffix}"
  description = "Write access to DynamoDB table"
  policy      = data.aws_iam_policy_document.indoor-air-test-table-write-policy-doc.json

  tags = local.tags
}

resource "aws_iam_role" "indoor-air-test-write-role" {
  name                = "IndoorAirObservation-Write${local.name_suffix}"
  assume_role_policy  = data.aws_iam_policy_document.lambda-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.indoor-air-test-table-write-policy.arn, "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  tags = local.tags
}

resource "aws_lambda_function" "put-indoor-air-observation-function" {
  filename      = "${var.lambda_archives_path}/put_indoor_air_obs.zip"
  function_name = "PutIndoorAirObservation${local.name_suffix}"
  role          = aws_iam_role.indoor-air-test-write-role.arn
  handler       = "put_indoor_air_obs.lambda_handler"

  source_code_hash = filebase64sha256("${var.lambda_archives_path}/put_indoor_air_obs.zip")

  runtime     = "python3.9"
  memory_size = "128"
  timeout     = "5"

  environment {
    variables = {
      REGION       = "ap-southeast-2"
      DYNAMO_TABLE = aws_dynamodb_table.indoor-air-test-dynamodb-table.name
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "indoor-observation" {
  name = "/aws/lambda/${aws_lambda_function.put-indoor-air-observation-function.function_name}"

  retention_in_days = 30

  tags = local.tags
}

resource "aws_apigatewayv2_api" "indoor-air-restapi" {
  name          = "IndoorAirObservationAPI${local.name_suffix}"
  protocol_type = "HTTP"

  tags = local.tags
}

resource "aws_apigatewayv2_stage" "indoor-air-restapi-stage" {
  api_id = aws_apigatewayv2_api.indoor-air-restapi.id

  name        = "IndoorAirObservationAPI-v1${local.name_suffix}"
  auto_deploy = true

  tags = local.tags
}

resource "aws_apigatewayv2_integration" "indoor-air-restapi-integration" {
  api_id = aws_apigatewayv2_api.indoor-air-restapi.id

  integration_uri    = aws_lambda_function.put-indoor-air-observation-function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "indoor-air-restapi-post-observation" {
  api_id = aws_apigatewayv2_api.indoor-air-restapi.id

  route_key = "POST /observation"
  target    = "integrations/${aws_apigatewayv2_integration.indoor-air-restapi-integration.id}"
}

resource "aws_lambda_permission" "indoor-air-lambda-permission" {
  statement_id  = "AllowExecutionFromIndoorAirAPI${local.name_suffix}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put-indoor-air-observation-function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.indoor-air-restapi.execution_arn}/*/*"
}

resource "aws_resourcegroups_group" "indoor-air-rg" {
  name = "RG${local.name_suffix}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "project",
      "Values": ["${var.project_name}"]
    }
  ]
}
JSON
  }

  tags = local.tags
}
