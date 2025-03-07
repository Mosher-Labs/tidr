data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_manipulation" {
  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:TagRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.name}*",
    ]
  }

  statement {
    actions = [
      "iam:TagPolicy",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name}*",
    ]
  }
}
