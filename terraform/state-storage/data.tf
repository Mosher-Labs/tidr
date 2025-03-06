# data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "requisite_permissions" {
  statement {
    actions = [
      "iam:AttachUserPolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:DetachUserPolicy",
      "iam:Get*",
      "iam:List*",
      "s3:PutBucketVersioning",
    ]

    resources = [
      "arn:aws:iam:::user/${var.config.name}*",
      "arn:aws:iam:::policy/${var.config.name}*",
      "arn:aws:s3:::${var.config.name}*",
    ]
  }
}

# data "aws_iam_policy_document" "state_storage" {
#   statement {
#     actions = [
#       "iam:AttachUserPolicy",
#       "iam:CreatePolicy",
#     ]
#
#     resources = [
#       provider::aws::arn_build("aws", "iam", "", data.aws_caller_identity.current.account_id, "policy/${var.config.name}*"),
#       "arn:aws:iam::aws:user/z_terraform"
#     ]
#   }
#
#   statement {
#     actions = [
#       "s3:CreateBucket",
#       "s3:DeleteBucket",
#     ]
#
#     resources = [
#       local.s3_arn_namespace,
#     ]
#   }
#
#   statement {
#     actions = [
#       "s3:ListBucket",
#     ]
#
#     resources = [
#       local.s3_arn_namespace,
#     ]
#   }
#
#   statement {
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#     ]
#
#     resources = [
#       local.s3_arn_namespace,
#       "${local.s3_arn_namespace}/*",
#     ]
#   }
#
#   statement {
#     actions = [
#       "s3:DeleteObject",
#     ]
#
#     resources = [
#       "${local.s3_arn_namespace}/*.tflock",
#     ]
#   }
# }
#
# data "aws_iam_policy_document" "manage_state_storage" {
#   statement {
#     actions = [
#       "s3:PutBucketVersioning",
#     ]
#
#     resources = [
#       local.s3_arn_namespace
#     ]
#   }
#
#   statement {
#     actions = [
#       "iam:DetachUserPolicy",
#     ]
#
#     resources = [
#       "arn:aws:iam::aws:user/z_terraform"
#     ]
#   }
#
# }

