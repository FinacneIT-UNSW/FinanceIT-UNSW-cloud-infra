resource "aws_dynamodb_table" "connections" {
  name           = "WebsocketAPIConnections${var.name_suffix}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }

  tags = var.tags
}

data "aws_iam_policy_document" "dynamo-crud-doc" {
  statement {
    actions   = [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ]
    resources = [aws_dynamodb_table.connections.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "dynamo-crud-policy" {
  name        = "WebsocketConnectionsTable-CRUD${var.name_suffix}"
  policy      = data.aws_iam_policy_document.dynamo-crud-doc.json

  tags = var.tags
}
