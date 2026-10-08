resource "aws_apigatewayv2_api" "api_gateway_blog_lab05" {
  name          = "api_blog_lab05"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      "https://www.blog-lab05-cloudfront.shop",
      "https://blog-lab05-cloudfront.shop"
    ]

    allow_methods = [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "OPTIONS",
    ]

    allow_headers = [
      "Content-Type",
      "Authorization",
    ]
    max_age = 300
  }
}

resource "aws_apigatewayv2_integration" "api_gateway_blog_lab05_integration" {
  api_id                 = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  description            = "Lambda integration for blog-lab05"
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.blog_lab05_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_gateway_blog_lab05_route_get_all" {
  api_id    = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  route_key = "GET /posts"
  target    = "integrations/${aws_apigatewayv2_integration.api_gateway_blog_lab05_integration.id}"
}

resource "aws_apigatewayv2_route" "api_gateway_blog_lab05_route_get" {
  api_id    = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  route_key = "GET /posts/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.api_gateway_blog_lab05_integration.id}"
}

resource "aws_apigatewayv2_route" "api_gateway_blog_lab05_route" {
  api_id             = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  route_key          = "POST /posts"
  target             = "integrations/${aws_apigatewayv2_integration.api_gateway_blog_lab05_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.blog_lab05_authorizer.id
}

resource "aws_apigatewayv2_route" "api_gateway_blog_lab05_route_put" {
  api_id             = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  route_key          = "PUT /posts/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.api_gateway_blog_lab05_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.blog_lab05_authorizer.id
}

resource "aws_apigatewayv2_route" "api_gateway_blog_lab05_route_delete" {
  api_id             = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  route_key          = "DELETE /posts/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.api_gateway_blog_lab05_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.blog_lab05_authorizer.id
}


resource "aws_apigatewayv2_stage" "api_gateway_blog_lab05_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  name        = "Dev"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway_blog_lab05_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.blog_lab05_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway_blog_lab05.execution_arn}/*/*"
}

resource "aws_apigatewayv2_authorizer" "blog_lab05_authorizer" {
  api_id           = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "blog-lab05-jwt-authorizer"

  jwt_configuration {
    audience = [
      aws_cognito_user_pool_client.blog_lab05_user_pool_client.id
    ]

    issuer = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.blog_lab05_user_pool.id}"
  }
}