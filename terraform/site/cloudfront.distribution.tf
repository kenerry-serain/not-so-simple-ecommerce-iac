resource "aws_cloudfront_distribution" "this" {

  enabled             = var.cloudfront.enabled
  default_root_object = var.cloudfront.default_root_object
  price_class         = var.cloudfront.price_class

  aliases = [var.cloudfront.domain]
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = aws_s3_bucket.site.bucket_regional_domain_name
  }

  default_cache_behavior {
    allowed_methods        = var.cloudfront.default_cache_behavior.allowed_methods
    cached_methods         = var.cloudfront.default_cache_behavior.cached_methods
    target_origin_id       = aws_s3_bucket.site.bucket_regional_domain_name
    cache_policy_id        = var.cloudfront.default_cache_behavior.cache_policy_id
    viewer_protocol_policy = var.cloudfront.default_cache_behavior.viewer_protocol_policy
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.this.arn
    ssl_support_method  = "sni-only"
  }
}
