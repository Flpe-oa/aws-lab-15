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

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.s3_frontend.id
  key          = "index.html"
  source       = "${path.module}/../website/index.html"
  content_type = "text/html; charset=utf-8"

  etag = filemd5("${path.module}/../website/index.html")
}

resource "aws_s3_bucket_policy" "s3_frontend" {
  bucket = aws_s3_bucket.s3_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Sid    = "AllowCloudFrontServicePrincipalReadOnly"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.s3_frontend.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.frontend_distribution.arn
        }
      }
    }]
  })
}