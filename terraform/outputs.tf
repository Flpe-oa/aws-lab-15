output "frontend_url" {
  description = "URL principal do frontend entregue pelo CloudFront."
  value       = "https://${local.domain}"
}

output "api_base_url" {
  description = "URL base da API HTTP no API Gateway."
  value       = aws_apigatewayv2_stage.api_gateway_blog_lab05_stage.invoke_url
}

output "cognito_user_pool_id" {
  description = "ID do Cognito User Pool usado pela aplicação."
  value       = aws_cognito_user_pool.blog_lab05_user_pool.id
}

output "cognito_user_pool_client_id" {
  description = "ID do App Client do Cognito usado no frontend."
  value       = aws_cognito_user_pool_client.blog_lab05_user_pool_client.id
}

output "media_bucket_name" {
  description = "Nome do bucket S3 usado para armazenar mídias do blog."
  value       = aws_s3_bucket.blog_media_bucket.bucket
}