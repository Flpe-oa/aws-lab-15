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