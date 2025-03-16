module "z" {
  source = "./modules/application"

  config = {
    name = local.name
  }

  depends_on = [
    aws_iam_policy.terraform_manipulation,
    aws_iam_policy_attachment.terraform_manipulation
  ]
}
