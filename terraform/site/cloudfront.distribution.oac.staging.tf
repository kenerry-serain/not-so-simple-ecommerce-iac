resource "aws_cloudfront_origin_access_control" "staging" {
  name                              = "${aws_s3_bucket.staging_site.bucket_regional_domain_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}