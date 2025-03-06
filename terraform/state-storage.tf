provider "aws" {
  region = var.aws_config.region
}

terraform {
  backend "s3" {
    bucket         = var.state_storage_config.bucket
    key            = var.state_storage_config.key
    region         = try(var.state_storage_config.region, var.aws_config.region)
    encrypt        = var.state_storage_config.encrypt
    dynamodb_table = try(var.state_storage_config.dynamodb_table, var.state_storage_config.bucket)
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_storage_config.bucket
  acl    = var.stage_storage_config.acl
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = try(var.state_storage_config.dynamodb_table, var.state_storage_config.bucket)
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

