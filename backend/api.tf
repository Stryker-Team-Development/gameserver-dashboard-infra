resource "aws_api_gateway_rest_api" "api" {
  name        = "ValheimDashBoardAPI"
  description = "API for querying information for Valheim server"
}

resource "aws_api_gateway_resource" "server" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
   path_part   = "server"
}

resource "aws_api_gateway_method" "server" {
   rest_api_id   = aws_api_gateway_rest_api.api.id
   resource_id   = aws_api_gateway_resource.server.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   resource_id = aws_api_gateway_method.server.resource_id
   http_method = aws_api_gateway_method.server.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.status.invoke_arn
}

# Cors
module "status_cors" {
    source = "./cors"

    rest_api_id = aws_api_gateway_rest_api.api.id
    resource_id = aws_api_gateway_resource.server.id
}
