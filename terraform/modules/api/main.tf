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
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
      ]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda-logging-policy" {
  name        = "LambdaLogging${var.name_suffix}"
  description = "Grant Access to logging"
  policy      = data.aws_iam_policy_document.lambda-logging-policy-doc.json

  tags = var.tags
}

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.table.name}API${var.name_suffix}"
  api_key_source = "HEADER"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_resource" "point" {
  path_part   = "point"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}


resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.point.id,
      aws_api_gateway_method.point-post.id,
      aws_api_gateway_integration.point-post-put.id,
      aws_api_gateway_method.point-get.id,
      aws_api_gateway_integration.point-get-query.id,
      filebase64sha256("${var.lambda_archives_path}/point_put.zip")
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "${aws_api_gateway_rest_api.api.name}-v1"

  tags = var.tags
}

resource "aws_api_gateway_usage_plan" "api-usage-plan" {
  name = "UsagePlan1"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.v1.stage_name
  }

  tags = var.tags
}

resource "aws_api_gateway_api_key" "api-key" {
  name = "APIKEY-${aws_api_gateway_rest_api.api.name}"

  tags = var.tags
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.api-key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api-usage-plan.id
}
