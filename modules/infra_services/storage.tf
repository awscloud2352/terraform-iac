resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.cloud_env}-${var.bucket_name}"
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
