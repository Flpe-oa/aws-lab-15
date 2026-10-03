resource "aws_wafv2_web_acl" "blog_lab05_waf" {
  name        = "blog-lab05-waf"
  description = "WAF for blog-lab05 CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "CrossSiteScripting_QueryArguments"

          action_to_use {
            block {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  #   rule {
  #     name     = "RateLimitByIP"
  #     priority = 2

  #     action {
  #       block {}
  #     }

  #     statement {
  #       rate_based_statement {
  #         limit              = 10
  #         aggregate_key_type = "IP"
  #       }
  #     }

  #     visibility_config {
  #       cloudwatch_metrics_enabled = true
  #       metric_name                = "RateLimitByIP"
  #       sampled_requests_enabled   = true
  #     }
  #   }

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