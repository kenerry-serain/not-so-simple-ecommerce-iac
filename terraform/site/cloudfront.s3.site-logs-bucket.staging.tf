resource "aws_s3_bucket" "staging_site_logs" {
  bucket        = var.cloudfront.s3_staging_site_logs_bucket_name
  force_destroy = true
}
