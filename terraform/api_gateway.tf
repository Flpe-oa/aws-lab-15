resource "aws_apigatewayv2_api" "api_gateway_blog_lab05" {
  name          = "api_blog_lab05"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "api_gateway_blog_lab05_integration" {
  api_id                 = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  description            = "Lambda integration for blog-lab05"
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.blog_lab05_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_gateway_blog_lab05_route" {
  api_id    = aws_apigatewayv2_api.api_gateway_blog_lab05.id
  route_key = "POST /posts"
  target    = "integrations/${aws_apigatewayv2_integration.api_gateway_blog_lab05_integration.id}"
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