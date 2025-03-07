resource "aws_iam_role" "lambda_execution" {
  assume_role_policy = data.aws_iam_policy_document.lambda_execution.json
  name               = "${var.config.name}_lambda_execution"

  tags = {
    Name = "${var.config.name}_lambda_execution"
  }
}

resource "aws_iam_policy" "lambda_s3" {
  name        = "${var.config.name}_lambda_s3"
  description = "Least privilege policy for Lambda to access specific S3 bucket"
  policy      = data.aws_iam_policy_document.lambda_s3.json

  tags = {
    Name = "${var.config.name}_lambda_s3"
  }
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${var.config.name}_lambda_dynamodb"
  description = "Least privilege policy for Lambda to access specific DynamoDB table"
  policy      = data.aws_iam_policy_document.lambda_dynamodb.json

  tags = {
    Name = "${var.config.name}_lambda_dynamodb"
  }
}

resource "aws_iam_policy_attachment" "lambda_s3" {
  name       = "${var.config.name}_lambda_s3"
  policy_arn = aws_iam_policy.lambda_s3.arn
  roles = [
    aws_iam_role.lambda_execution.name
  ]
}

resource "aws_iam_policy_attachment" "lambda_dynamodb" {
  name       = "${var.config.name}_lambda_dynamodb"
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
  roles = [
    aws_iam_role.lambda_execution.name
  ]
}

