output "table" {
  value = {
    name          = aws_dynamodb_table.main-table.name,
    arn           = aws_dynamodb_table.main-table.arn,
    stream        = var.isstream ? aws_dynamodb_table.main-table.stream_arn : null
    policy_crud   = aws_iam_policy.dynamo-crud-policy.arn
    policy_stream = aws_iam_policy.read-stream-doc-policy.arn
  }
}
