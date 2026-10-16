resource "aws_dynamodb_table" "blog_lab05_table" {
  name         = "blog-lab05-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "blog-lab05-table"
  }
}