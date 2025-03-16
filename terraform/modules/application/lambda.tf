resource "aws_iam_role" "lambda_execution" {
  assume_role_policy = data.aws_iam_policy_document.lambda_execution.json
  name               = "${var.config.name}_lambda_execution"

  tags = {
    Name = "${var.config.name}_lambda_execution"
  }
}

