locals {
  # state_bucket_name = replace("${var.config.name}_state_storage", "_", "-")
  # s3_arn_namespace  = provider::aws::arn_build("aws", "s3", "", "", "${var.config.name}*")
}
