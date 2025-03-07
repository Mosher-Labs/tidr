resource "aws_iam_policy" "terraform_manipulation" {
  name        = "${local.name}_terraform_manipulation"
  description = "Permissions to apply the required resources for the application via Terraform."
  policy      = data.aws_iam_policy_document.terraform_manipulation.json
}

resource "aws_iam_policy_attachment" "terraform_manipulation" {
  name       = "${local.name}_terraform_manipulation"
  policy_arn = aws_iam_policy.terraform_manipulation.arn
  users = [
    "z_terraform"
  ]
}
