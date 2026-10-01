resource "aws_wafv2_web_acl" "blog_lab05_waf" {
  name        = "blog-lab05-waf"
  description = "WAF for blog-lab05 CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "blog-lab05-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "blog-lab05-waf"
    Environment = "Dev"
  }
}