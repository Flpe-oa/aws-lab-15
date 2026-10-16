locals {
  domain = var.domain_name

  allowed_origins = [
    "https://${local.domain}",
    "https://www.${local.domain}",
  ]

  aliases = [
    local.domain,
    "www.${local.domain}",
  ]

  cloudfront_records = {
    root      = { name = local.domain, type = "A" }
    root_ipv6 = { name = local.domain, type = "AAAA" }
    www       = { name = "www.${local.domain}", type = "A" }
    www_ipv6  = { name = "www.${local.domain}", type = "AAAA" }
  }
}