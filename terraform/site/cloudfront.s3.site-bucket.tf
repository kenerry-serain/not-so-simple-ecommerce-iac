resource "aws_s3_bucket" "site" {
  bucket        = var.cloudfront.s3_site_bucket_name
  force_destroy = true
}
