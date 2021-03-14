provider "aws" {
  region  = "us-east-2"
  profile = "new-aleochoam"
  alias   = "ohio"
}

data "aws_instance" "server" {
  provider = aws.ohio
  filter {
    name   = "tag:Name"
    values = ["Valheim-Server"]
  }
}

resource "aws_iam_role" "lambda_status_exec" {
  name = "LambdaStatusIAMRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role" "lambda_state_exec" {
  name = "LambdaStateIAMRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

# Status endpoint
resource "aws_lambda_function" "status" {
  function_name = "StatusLambda"

  handler  = "main.handler"
  runtime  = "python3.7"
  filename = "./lambda.zip"
  timeout  = 10

  role = aws_iam_role.lambda_status_exec.arn

  environment {
    variables = {
      INSTANCE_ID = data.aws_instance.server.id
    }
  }

  tags = var.tags
}

resource "aws_lambda_function" "state" {
  function_name = "StateLambda"

  handler  = "main.handler"
  runtime  = "python3.7"
  filename = "./lambda.zip"
  timeout  = 10

  role = aws_iam_role.lambda_state_exec.arn

  environment {
    variables = {
      INSTANCE_ID = data.aws_instance.server.id
    }
  }

  tags = var.tags
}

resource "aws_iam_policy" "policy" {
  name        = "StartStopServerPolicy"
  path        = "/"
  description = "Allow to start and stop the Valheim server"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Effect   = "Allow"
        Resource = data.aws_instance.server.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "status_lambda_execution" {
  role       = aws_iam_role.lambda_status_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "state_lambda_execution" {
  role       = aws_iam_role.lambda_state_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ec2_reader" {
  role       = aws_iam_role.lambda_status_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_state_changer" {
  role       = aws_iam_role.lambda_state_exec.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_lambda_permission" "apigw_status" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.status.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_state" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.state.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
