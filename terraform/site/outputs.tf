output "s3_site_bucket_domain" {
  value = aws_s3_bucket.site.bucket_regional_domain_name
}

output "s3_site_logs_bucket_domain" {
  value = aws_s3_bucket.site_logs.bucket_regional_domain_name
}