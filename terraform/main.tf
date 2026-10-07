resource "aws_s3_bucket" "s3_frontend" {
  bucket = "medium-blog-frontend-lab05"

  tags = {
    Name        = "frontend-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "s3_frontend_versioning" {
  bucket = aws_s3_bucket.s3_frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_frontend_public_access_block" {
  bucket = aws_s3_bucket.s3_frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  frontend_files = {
    "index.html" = {
      source       = "${path.module}/../website/index.html"
      content_type = "text/html; charset=utf-8"
    }

    "css/style.css" = {
      source       = "${path.module}/../website/css/style.css"
      content_type = "text/css"
    }

    "js/app.js" = {
      source       = "${path.module}/../website/js/app.js"
      content_type = "application/javascript"
    }
  }
}

resource "aws_s3_object" "frontend" {
  for_each = local.frontend_files

  bucket = aws_s3_bucket.s3_frontend.id

  key          = each.key
  source       = each.value.source
  content_type = each.value.content_type
  etag         = filemd5(each.value.source)
}

resource "aws_s3_bucket_policy" "s3_frontend" {
  bucket = aws_s3_bucket.s3_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action = "s3:GetObject"

        Resource = "${aws_s3_bucket.s3_frontend.arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend_distribution.arn
          }
        }
      }
    ]
  })
}