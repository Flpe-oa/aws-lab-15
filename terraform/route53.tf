resource "aws_route53_zone" "blog-lab05-cloudfront" {
  name = "blog-lab05-cloudfront.shop"

  tags = {
    Name = var.domain_name
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

locals {
  domain = var.domain_name

  allowed_origins = [
    "https://${local.domain}",
    "https://www.${local.domain}",
  ]

  cloudfront_records = {
    root      = { name = local.domain, type = "A" }
    root_ipv6 = { name = local.domain, type = "AAAA" }
    www       = { name = "www.${local.domain}", type = "A" }
    www_ipv6  = { name = "www.${local.domain}", type = "AAAA" }
  }
}

resource "aws_route53_record" "cloudfront" {
  for_each = local.cloudfront_records

  zone_id = aws_route53_zone.blog-lab05-cloudfront.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

