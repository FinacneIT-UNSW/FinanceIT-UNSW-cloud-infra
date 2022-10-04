output "endpoint" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_api.websocket.api_endpoint
}