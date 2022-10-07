resource "aws_dynamodb_table" "main-table" {

  name           = "${var.table_name}${var.name_suffix}"
  billing_mode   = "PROVISIONED"

  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  hash_key       = var.hash_key_name
  range_key      = var.sort_key_name

  stream_enabled = var.isstream
  stream_view_type = var.isstream ? var.stream_type : null

  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }

  attribute {
    name = var.sort_key_name
    type = var.sort_key_type
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
    resources = [aws_dynamodb_table.main-table.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "dynamo-crud-policy" {
  name        = "${aws_dynamodb_table.main-table.name}-CRUD"
  policy      = data.aws_iam_policy_document.dynamo-crud-doc.json

  tags = var.tags
}

data "aws_iam_policy_document" "read-stream-doc" {
  statement {
    actions   = [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
            ]
    resources = [aws_dynamodb_table.main-table.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "read-stream-doc-policy" {
  name        = "${aws_dynamodb_table.main-table.name}-STREAM"
  policy      = data.aws_iam_policy_document.read-stream-doc.json

  tags = var.tags
}
