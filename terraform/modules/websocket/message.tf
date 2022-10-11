resource "aws_iam_role" "connections-message" {
  name               = "WebsocketConnectionMessageLambda${var.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
  managed_policy_arns = [
    aws_iam_policy.manage-connections-policy.arn,
    aws_iam_policy.dynamo-crud-policy.arn,
    var.table.policy_crud,
    var.table.policy_stream,
    aws_iam_policy.lambda-logging-policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = var.tags
}

resource "aws_lambda_function" "message" {
  filename      = var.message.file_path
  function_name = "WebsocketMessage${var.name_suffix}"
  role          = aws_iam_role.connections-message.arn
  handler       = var.message.handler

  source_code_hash = filebase64sha256(var.message.file_path)

  runtime     = var.message.runtime
  memory_size = var.message.memory_size
  timeout     = var.message.timeout

  environment {
    variables = {
      REGION                = "ap-southeast-2"
      CONNECTION_TABLE_NAME = aws_dynamodb_table.connections.name
    }
  }

  depends_on = [
    aws_iam_role.connections-message
  ]

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "event" {
  event_source_arn  = var.table.stream
  function_name     = aws_lambda_function.message.function_name
  starting_position = "LATEST"
}

resource "aws_cloudwatch_log_group" "message" {
  name = "/aws/lambda/${aws_lambda_function.message.function_name}"

  retention_in_days = 30
  tags              = var.tags
}
