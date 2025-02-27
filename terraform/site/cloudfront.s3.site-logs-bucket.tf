resource "aws_s3_bucket" "site_logs" {
  bucket = var.cloudfront.s3_site_logs_bucket_name
}