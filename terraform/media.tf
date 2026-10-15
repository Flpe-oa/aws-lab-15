resource "aws_s3_bucket" "blog_media_bucket" {
  bucket = "blog-lab05-media"

  tags = {
    Name = "blog-lab05-media"
  }
}

resource "aws_s3_bucket_versioning" "blog_media_bucket_versioning" {
  bucket = aws_s3_bucket.blog_media_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "blog_media_bucket_public_access_block" {
  bucket = aws_s3_bucket.blog_media_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "blog_media_bucket_cors" {
  bucket = aws_s3_bucket.blog_media_bucket.id

  cors_rule {
    allowed_origins = local.allowed_origins

    allowed_methods = [
      "PUT",
      "GET",
      "HEAD"
    ]

    allowed_headers = [
      "Content-Type"
    ]

    expose_headers = [
      "ETag"
    ]

    max_age_seconds = 300
  }
}