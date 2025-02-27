resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${aws_s3_bucket.site.bucket_regional_domain_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
