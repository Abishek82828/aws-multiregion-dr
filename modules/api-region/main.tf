data "aws_caller_identity" "current" {
  provider = aws
}

data "aws_region" "current" {
  provider = aws
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "${path.module}/build/${var.region_suffix}.zip"
}

resource "aws_iam_role" "lambda_exec" {
  provider = aws
  name     = "${var.project_name}-lambda-${var.region_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  provider   = aws
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_access" {
  provider = aws
  name     = "${var.project_name}-dynamodb-${var.region_suffix}"
  role     = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:Query",
      ]
      Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
    }]
  })
}

resource "aws_lambda_function" "api" {
  provider = aws

  function_name = "${var.project_name}-api-${var.region_suffix}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 10

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  provider      = aws
  name          = "${var.project_name}-api-${var.region_suffix}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  provider               = aws
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "items_get" {
  provider  = aws
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "items_post" {
  provider  = aws
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /items"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "health" {
  provider  = aws
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  provider    = aws
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  provider      = aws
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
