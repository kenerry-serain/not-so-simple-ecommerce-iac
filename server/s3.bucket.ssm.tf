resource "aws_s3_bucket" "ansible_ssm" {
  bucket = var.bucket_ssm
  tags   = var.tags
}
