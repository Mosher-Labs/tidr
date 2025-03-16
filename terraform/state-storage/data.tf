data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "requisite_permissions" {
  statement {
    actions = [
      "iam:AttachUserPolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DetachUserPolicy",
      "iam:Get*",
      "iam:List*",
      "iam:TagPolicy",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.config.name}*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.config.name}*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/z_terraform",
    ]
  }

  statement {
    actions = [
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
    ]
    resources = [
      "arn:aws:s3:::${local.dashed_name}*",
    ]
  }
}

data "aws_iam_policy_document" "state_storage" {
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:ListBucket",
      "s3:PutBucketVersioning",
    ]

    resources = [
      "arn:aws:s3:::${local.dashed_name}*",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.dashed_name}*",
      "arn:aws:s3:::${local.dashed_name}*/*",
    ]
  }

  statement {
    actions = [
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${local.dashed_name}*/*.tflock",
    ]
  }
}
