resource "aws_cognito_user_pool" "blog_lab05_user_pool" {
  name = "blog-lab05-user-pool"

  username_attributes = ["email"]

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  tags = {
    Name        = "blog-lab05-user-pool"
    Environment = "Dev"
  }
}

resource "aws_cognito_user_pool_client" "blog_lab05_user_pool_client" {
  name         = "blog-lab05-user-pool-client"
  user_pool_id = aws_cognito_user_pool.blog_lab05_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
  generate_secret = false
}

resource "aws_cognito_user" "blog_lab05_test_user" {
  user_pool_id = aws_cognito_user_pool.blog_lab05_user_pool.id

  username = "teste@blog-lab05.com"
  password = "BlogLab05@123"

  attributes = {
    email          = "teste@blog-lab05.com"
    email_verified = "true"
  }
}

