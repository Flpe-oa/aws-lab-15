resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name              = aws_s3_bucket.s3_frontend.bucket_regional_domain_name
    origin_id                = "s3_frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_frontend_oac.id

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for frontend"
  default_root_object = "index.html"

  aliases = local.aliases

  web_acl_id = aws_wafv2_web_acl.blog_lab05_waf.arn

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_frontend"

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "s3_frontend_oac" {
  name                              = "s3_frontend_oac"
  description                       = "OAC Policy for S3 Frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

action "aws_cloudfront_create_invalidation" "frontend" {
  config {
    distribution_id = aws_cloudfront_distribution.frontend_distribution.id
    paths           = ["/*"]
  }
}

resource "terraform_data" "invalidate_frontend" {
  triggers_replace = [for o in aws_s3_object.frontend : o.etag]

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_cloudfront_create_invalidation.frontend]
    }
  }

  depends_on = [aws_s3_object.frontend]
}