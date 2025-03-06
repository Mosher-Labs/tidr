# # TODO: User official OSS S3 TF module
resource "aws_s3_bucket" "state_storage" {
  bucket = "${local.dashed_name}-state-storage"
}

resource "aws_s3_bucket_versioning" "state_storage" {
  bucket = aws_s3_bucket.state_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

