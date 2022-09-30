data "aws_iam_policy_document" "indoor-air-test-table-query-policy-doc" {
  statement {
    actions   = ["dynamodb:Query"]
    resources = [aws_dynamodb_table.indoor-air-test-dynamodb-table.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "indoor-air-test-table-query-policy" {
  name        = "IndoorAirObservation-Query${local.name_suffix}"
  description = "Query access to DynamoDB table"
  policy      = data.aws_iam_policy_document.indoor-air-test-table-query-policy-doc.json

  tags = local.tags
}

resource "aws_iam_role" "indoor-air-test-query-role" {
  name                = "IndoorAirObservation-Query${local.name_suffix}"
  assume_role_policy  = data.aws_iam_policy_document.lambda-assume-role-policy.json
  managed_policy_arns = [
    aws_iam_policy.indoor-air-test-table-query-policy.arn,
    aws_iam_policy.lambda-logging-policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = local.tags
}

resource "aws_lambda_permission" "apigw_lambda_get_indoor" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query-indoor-air-observation-function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:ap-southeast-2:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.api-observation-get.http_method}${aws_api_gateway_resource.api-observation.path}"
}

resource "aws_lambda_function" "query-indoor-air-observation-function" {
  filename      = "${var.lambda_archives_path}/get_indoor_obs.zip"
  function_name = "GetIndoorAirObservation${local.name_suffix}"
  role          = aws_iam_role.indoor-air-test-query-role.arn
  handler       = "get_indoor_obs.lambda_handler"

  source_code_hash = filebase64sha256("${var.lambda_archives_path}/get_indoor_obs.zip")

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

resource "aws_cloudwatch_log_group" "indoor-observation-get" {
  name = "/aws/lambda/${aws_lambda_function.query-indoor-air-observation-function.function_name}"

  retention_in_days = 30

  tags = local.tags
}