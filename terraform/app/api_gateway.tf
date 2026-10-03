resource "aws_api_gateway_deployment" "blog_lab05_deployment" {
  rest_api_id = aws_api_gateway_rest_api.blog_lab05_api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.blog_lab05_api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "blog_lab05_stage" {
  deployment_id = aws_api_gateway_deployment.blog_lab05_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.blog_lab05_api_gateway.id
  stage_name    = "dev"

}

