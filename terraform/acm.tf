resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain
  subject_alternative_names = ["*.${local.domain}"]
  validation_method         = "DNS"

  tags = {
    Name = "blog-lab05-cloudfront"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "blog-lab05-cloudfront" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.record_acm : record.fqdn
  ]
}