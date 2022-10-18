output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_api_gateway_stage.v1.invoke_url
}

output "api_key" {
  description = "API KEY value"

  value = {
    key_name   = aws_api_gateway_api_key.api-key.name,
    key_secret = aws_api_gateway_api_key.api-key.value
  }
  sensitive = true
}
