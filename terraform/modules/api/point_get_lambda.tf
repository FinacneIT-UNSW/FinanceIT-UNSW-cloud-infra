data "aws_iam_policy_document" "main-table-query-policy-doc" {
  statement {
    actions   = ["dynamodb:Query"]
    resources = [var.table.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "main-table-query-policy" {
  name        = "${var.table.name}-Query${var.name_suffix}"
  description = "Query access to DynamoDB table"
  policy      = data.aws_iam_policy_document.main-table-query-policy-doc.json

  tags = var.tags
}

resource "aws_iam_role" "query-point-lambda" {
  name                = "Query${var.table.name}${var.name_suffix}"
  assume_role_policy  = data.aws_iam_policy_document.lambda-assume-role-policy.json
  managed_policy_arns = [
    aws_iam_policy.main-table-query-policy.arn,
    aws_iam_policy.lambda-logging-policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = var.tags
}

resource "aws_lambda_permission" "execute-from-api-query-point" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query-point.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:ap-southeast-2:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.point-get.http_method}${aws_api_gateway_resource.point.path}"
}

resource "aws_lambda_function" "query-point" {
  filename      = "${var.lambda_archives_path}/point_query.zip"
  function_name = "Query${var.table.name}${var.name_suffix}"
  role          = aws_iam_role.query-point-lambda.arn
  handler       = "point_query.lambda_handler"

  source_code_hash = filebase64sha256("${var.lambda_archives_path}/point_query.zip")

  runtime     = "python3.9"
  memory_size = "128"
  timeout     = "5"

  environment {
    variables = {
      REGION       = "ap-southeast-2"
      DYNAMO_TABLE = var.table.name
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "query-point" {
  name = "/aws/lambda/${aws_lambda_function.query-point.function_name}"

  retention_in_days = 30

  tags = var.tags
}