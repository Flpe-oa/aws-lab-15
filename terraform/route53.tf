resource "aws_route53_zone" "blog-lab05-cloudfront" {
  name = "blog-lab05-cloudfront.shop"

  tags = {
    Name        = "blog-lab05-cloudfront"
    Environment = "Dev"
  }
}

resource "aws_route53_record" "record_acm" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.blog-lab05-cloudfront.zone_id
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.blog-lab05-cloudfront.zone_id
  name    = "www.blog-lab05-cloudfront.shop"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.blog-lab05-cloudfront.zone_id
  name    = "blog-lab05-cloudfront.shop"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_ipv6" {
  zone_id = aws_route53_zone.blog-lab05-cloudfront.zone_id
  name    = "www.blog-lab05-cloudfront.shop"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root_ipv6" {
  zone_id = aws_route53_zone.blog-lab05-cloudfront.zone_id
  name    = "blog-lab05-cloudfront.shop"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}