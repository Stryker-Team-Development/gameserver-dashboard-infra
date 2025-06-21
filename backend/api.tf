resource "aws_api_gateway_rest_api" "api" {
  name        = "MinecraftDashBoardAPI"
  description = "API for querying information for Minecraft server"
  tags        = var.tags
}

resource "aws_api_gateway_resource" "server" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "server"
}

resource "aws_api_gateway_resource" "server_state" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.server.id
  path_part   = "state"
}

resource "aws_api_gateway_method" "status_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.server.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "status_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.status_method.resource_id
  http_method = aws_api_gateway_method.status_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.status.invoke_arn
}

resource "aws_api_gateway_method" "state_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.server_state.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "state_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.state_method.resource_id
  http_method = aws_api_gateway_method.state_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.state.invoke_arn
}

# Cors
module "status_cors" {
  source = "./cors"

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.server.id
}

module "state_cors" {
  source = "./cors"

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.server_state.id
}
