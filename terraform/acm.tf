resource "aws_acm_certificate" "cert" {
  domain_name       = "blog-lab05-cloudfront.shop"
  subject_alternative_names = ["*.blog-lab05-cloudfront.shop"]
  validation_method = "DNS"

  tags = {
    Name = "blog-lab05-cloudfront"
    Environment = "Dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "blog-lab05-cloudfront" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.record_acm : record.fqdn
    ]
}