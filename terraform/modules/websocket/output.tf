output "endpoint" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.v1.invoke_url
}