resource "aws_iam_role" "put-point-lambda" {
  name                = "Post${var.table.name}-Lambda${var.name_suffix}"
  assume_role_policy  = data.aws_iam_policy_document.lambda-assume-role-policy.json
  managed_policy_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.table.name}-CRUD",
    aws_iam_policy.lambda-logging-policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = var.tags
}

resource "aws_lambda_permission" "execute-from-api-put-point" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put-point.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:ap-southeast-2:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.point-post.http_method}${aws_api_gateway_resource.point.path}"
}

resource "aws_lambda_function" "put-point" {
  filename      = var.post.file_path
  function_name = "Post${var.table.name}${var.name_suffix}"
  role          = aws_iam_role.put-point-lambda.arn
  handler       = var.post.handler

  source_code_hash = filebase64sha256(var.post.file_path)

  runtime     = var.post.runtime
  memory_size = var.post.memory_size
  timeout     = var.post.timeout

  environment {
    variables = {
      REGION       = "ap-southeast-2"
      DYNAMO_TABLE = var.table.name
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "put-point" {
  name = "/aws/lambda/${aws_lambda_function.put-point.function_name}"

  retention_in_days = 30

  tags = var.tags
}