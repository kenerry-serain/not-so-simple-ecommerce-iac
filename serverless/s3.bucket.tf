resource "aws_s3_bucket" "nsse" {
  bucket = var.s3_application_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "nsse_versioning" {
  bucket = aws_s3_bucket.nsse.id
  versioning_configuration {
    status = "Enabled"
  }
}
