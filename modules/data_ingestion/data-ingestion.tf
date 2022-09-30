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
  name        = "LambdaLogging${local.name_suffix}"
  description = "Grant Access to logging"
  policy      = data.aws_iam_policy_document.lambda-logging-policy-doc.json

  tags = local.tags
}

resource "aws_api_gateway_rest_api" "api" {
  name = "IndoorAirObservationAPI${local.name_suffix}"
  api_key_source = "HEADER"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.tags
}

resource "aws_api_gateway_resource" "api-observation" {
  path_part   = "observation"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_deployment" "api-deployement" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api-observation.id,
      aws_api_gateway_method.api-observation-post.id,
      aws_api_gateway_integration.api-observation-post-lambda.id,
      aws_api_gateway_method.api-observation-get.id,
      aws_api_gateway_integration.api-observation-get-lambda.id,
      filebase64sha256("${var.lambda_archives_path}/put_indoor_air_obs.zip")
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api-stage-v1" {
  deployment_id = aws_api_gateway_deployment.api-deployement.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "${aws_api_gateway_rest_api.api.name}-v1"

  tags = local.tags
}

resource "aws_api_gateway_usage_plan" "api-usage-plan" {
  name = "UsagePlan1"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.api-stage-v1.stage_name
  }

  tags = local.tags
}

resource "aws_api_gateway_api_key" "api-key" {
  name = "APIKEY-${aws_api_gateway_rest_api.api.name}"

  tags = local.tags
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.api-key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api-usage-plan.id
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
