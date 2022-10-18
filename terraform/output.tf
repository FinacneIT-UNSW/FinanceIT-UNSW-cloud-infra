data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = module.api.base_url
}

output "ingest_api_key" {
  description = "Ingest API KEY"

  value     = module.api.api_key
  sensitive = true
}

output "websocket" {
  description = "Base URL for API Gateway stage."

  value = module.websocket.endpoint
}
