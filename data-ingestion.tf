resource "aws_dynamodb_table" "indoor-air-test-dynamodb-table" {
  name           = "IndoorAir"
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

  tags = {
    Name= "indoor-air-db"
    Env = "dev"
  }
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
  name        = "indoor-air-test-table-write-policy"
  description = "Write access to DynamoDB table"
  policy      = data.aws_iam_policy_document.indoor-air-test-table-write-policy-doc.json
}

resource "aws_iam_role" "indoor-air-test-write-role" {
  name                = "indoor-air-test-write-role"
  assume_role_policy  = data.aws_iam_policy_document.lambda-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.indoor-air-test-table-write-policy.arn, "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_lambda_function" "put-indoor-air-observation-function" {
  filename      = "put_indoor_obs_lambda.zip"
  function_name = "put-indoor-air-observation"
  role          = aws_iam_role.indoor-air-test-write-role.arn
  handler       = "put_indoor_air_obs.lambda_handler"

  source_code_hash = filebase64sha256("put_indoor_obs_lambda.zip")

  runtime     = "python3.9"
  memory_size = "128"
  timeout     = "5"

  environment {
    variables = {
      REGION       = "ap-southeast-2"
      DYNAMO_TABLE = aws_dynamodb_table.indoor-air-test-dynamodb-table.name
    }
  }

  tags = {
      Name= "indoor-air-put-func"
    Env = "dev"
  }
}

resource "aws_cloudwatch_log_group" "indoor-observation" {
  name = "/aws/lambda/${aws_lambda_function.put-indoor-air-observation-function.function_name}"

  retention_in_days = 30
}

resource "aws_apigatewayv2_api" "indoor-air-restapi" {
  name          = "indoor-air-restapi"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "indoor-air-restapi-stage" {
  api_id = aws_apigatewayv2_api.indoor-air-restapi.id

  name        = "indoor-air-restapi-stage"
  auto_deploy = true

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
  statement_id  = "AllowExecutionFromIndoorAirAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put-indoor-air-observation-function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.indoor-air-restapi.execution_arn}/*/*"
}
