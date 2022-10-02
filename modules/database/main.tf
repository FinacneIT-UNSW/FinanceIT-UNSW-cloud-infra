resource "aws_dynamodb_table" "main-table" {
  name           = "${var.table_name}${var.name_suffix}"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "DeviceID"
  range_key      = "Timestamp"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "DeviceID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  tags = var.tags
}
