resource "aws_s3_bucket" "staging_site" {
  bucket        = var.cloudfront.s3_staging_site_bucket_name
  force_destroy = true
}
