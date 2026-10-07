output "frontend_distribution_domain" {
  value       = aws_cloudfront_distribution.frontend_distribution.domain_name
  description = "The domain name of the CloudFront distribution for the frontend"
}

output "frontend_distribution_id" {
  value       = aws_cloudfront_distribution.frontend_distribution.id
  description = "The ID of the CloudFront distribution for the frontend"
}

output "aws_route53_zone" {
  description = "Name servers of the hosted zone for the frontend"
  value       = aws_route53_zone.blog-lab05-cloudfront.name_servers
}

output "aws_acm_certificate" {
  description = "ARN of the ACM certificate for the frontend"
  value       = aws_acm_certificate.cert.arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway for the backend"
  value       = aws_apigatewayv2_stage.api_gateway_blog_lab05_stage.invoke_url
}

output "cognito_user_pool_id" {
  description = "ID do Cognito User Pool"
  value       = aws_cognito_user_pool.blog_lab05_user_pool.id
}

output "cognito_client_id" {
  description = "ID do Cognito App Client"
  value       = aws_cognito_user_pool_client.blog_lab05_user_pool_client.id
}