data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda-logging-policy-doc" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda-logging-policy" {
  name        = "LambdaLogging-2${var.name_suffix}"
  description = "Grant Access to logging"
  policy      = data.aws_iam_policy_document.lambda-logging-policy-doc.json

  tags = var.tags
}

resource "aws_apigatewayv2_api" "websocket" {
  name                       = "WebsocketStreamAPI"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

  tags = var.tags
}

resource "aws_apigatewayv2_route" "connect" {
  api_id    = aws_apigatewayv2_api.websocket.id
  target    = "integrations/${aws_apigatewayv2_integration.connect.id}"
  route_key = "$connect"
}

resource "aws_apigatewayv2_route" "disconnect" {
  api_id    = aws_apigatewayv2_api.websocket.id
  target    = "integrations/${aws_apigatewayv2_integration.disconnect.id}"
  route_key = "$disconnect"
}

resource "aws_apigatewayv2_integration" "connect" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS_PROXY"

  description        = "Handle Websocket Connections"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.manager.invoke_arn
}

resource "aws_apigatewayv2_integration" "disconnect" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS_PROXY"

  description        = "Handle Websocket Disconnections"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.manager.invoke_arn
}

resource "aws_apigatewayv2_deployment" "dep" {
  api_id      = aws_apigatewayv2_api.websocket.id
  description = "WebsocketAPI deployment"

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(jsonencode([
      filebase64sha256(var.manager.file_path),
      filebase64sha256(var.message.file_path)
    ]))

  }

  depends_on = [
    aws_apigatewayv2_route.connect,
    aws_apigatewayv2_route.disconnect
  ]
}

resource "aws_apigatewayv2_stage" "v1" {
  api_id        = aws_apigatewayv2_api.websocket.id
  name          = "${aws_apigatewayv2_api.websocket.name}-${var.stage_name}"
  deployment_id = aws_apigatewayv2_deployment.dep.id

  tags = var.tags
}
