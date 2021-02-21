provider "aws" {
  region  = "us-east-2"
  profile = "new-aleochoam"
  alias = "ohio"
}

data "aws_instance" "server" {
  provider = aws.ohio
  filter {
    name   = "tag:Name"
    values = ["Valheim-Server"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaIAMRole"

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

}

resource "aws_lambda_function" "status" {
  function_name = "StatusLambda"

  handler = "main.handler"
  runtime = "python3.7"
  filename = "./lambda.zip"
  timeout = 10

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      INSTANCE_ID = data.aws_instance.server.id
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_reader" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.status.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
