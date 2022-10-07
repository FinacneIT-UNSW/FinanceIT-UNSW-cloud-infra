data "aws_iam_policy_document" "manage-connections-doc" {
  statement {
    actions   = ["execute-api:ManageConnections"]
    resources = [
      aws_apigatewayv2_api.websocket.arn,
      "arn:aws:execute-api:ap-southeast-2:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.websocket.id}/${aws_apigatewayv2_api.websocket.name}v1/POST/*/*"
      ]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "manage-connections-policy" {
  name        = "ManageConnections-${aws_apigatewayv2_api.websocket.name}"
  policy      = data.aws_iam_policy_document.manage-connections-doc.json

  tags = var.tags
}

resource "aws_iam_role" "connections-manager" {
  name                = "WebsocketConnectionManagerLambda${var.name_suffix}"
  assume_role_policy  = data.aws_iam_policy_document.lambda-assume-role-policy.json
  managed_policy_arns = [
    aws_iam_policy.manage-connections-policy.arn,
    aws_iam_policy.dynamo-crud-policy.arn,
    aws_iam_policy.lambda-logging-policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = var.tags
}


resource "aws_lambda_function" "manager" {
  filename      = "${var.lambda_archives_path}/websocket_manager.zip"
  function_name = "WebsocketConnectionsManager${var.name_suffix}"
  role          = aws_iam_role.connections-manager.arn
  handler       = "websocket_manager.handler"

  source_code_hash = filebase64sha256("${var.lambda_archives_path}/websocket_manager.zip")

  runtime     = "python3.9"
  memory_size = "128"
  timeout     = "20"

  environment {
    variables = {
      REGION       = "ap-southeast-2"
      CONNECTION_TABLE_NAME = aws_dynamodb_table.connections.name
    }
  }

  tags = var.tags
}

resource "aws_lambda_permission" "execute-from-api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.manager.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:ap-southeast-2:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.websocket.id}/${aws_apigatewayv2_stage.v1.name}/*"
}

resource "aws_cloudwatch_log_group" "manager" {
  name = "/aws/lambda/${aws_lambda_function.manager.function_name}"

  retention_in_days = 30
  tags = var.tags
}