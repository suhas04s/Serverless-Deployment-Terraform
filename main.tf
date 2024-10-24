### S3 Bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "devopsmasterbucket23"
}

### DynamoDB Table
resource "aws_dynamodb_table" "my_table" {
  name           = "studentData"
  hash_key       = "studentid"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "studentid"
    type = "S"
  }
}

# Data Archive for Lambda function code
data "archive_file" "lambda_get" {
  type        = "zip"
  source_dir  = "${path.module}/SERVERLEES-main/getStudents.py"
  output_path = "${path.module}/SERVERLEES-main/getStudents.zip"
}

data "archive_file" "lambda_post" {
  type        = "zip"
  source_dir  = "${path.module}/SERVERLEES-main/insertStudentData.py"
  output_path = "${path.module}/SERVERLEES-main/insertStudentData.zip"
}

### IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
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

### Attach Policy to Role
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "dynamodb:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# policy attachment block 

resource "aws_iam_role_policy_attachment" "attch_ima_policy_to_role" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_role_policy.lambda_policy.policy_arn  
}

# Lambda GET
resource "aws_lambda_function" "get_function" {
  filename         = data.archive_file.lambda_get.output_path
  function_name    = "getLambdaFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "getStudents.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(data.archive_file.lambda_get.output_path)

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.my_table.name
      # S3_BUCKET    = aws_s3_bucket.lambda_bucket.bucket
    }
  }
}

# Lambda POST
resource "aws_lambda_function" "post_function" {
  filename         = data.archive_file.lambda_post.output_path
  function_name    = "postLambdaFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "insertStudentData.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(data.archive_file.lambda_post.output_path)

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.my_table.name
    #   S3_BUCKET    = aws_s3_bucket.lambda_bucket.bucket
    }
  }
}

### API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name = "my_api"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

### API Gateway Resources and Methods
# Root Resource
resource "aws_api_gateway_resource" "root_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "items"
}  

# GET Method
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.root_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.get_function.invoke_arn
}


# POST Method
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.root_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.post_function.invoke_arn
}

### Deploy API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_api_gateway_integration.get_integration, aws_api_gateway_integration.post_integration]
}

resource "aws_lambda_permission" "api_lambda_permission" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.get_function.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/*"
  
}

