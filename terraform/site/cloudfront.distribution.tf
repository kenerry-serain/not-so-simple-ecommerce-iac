resource "aws_cloudfront_distribution" "this" {
  enabled                         = var.cloudfront.enabled
  default_root_object             = var.cloudfront.default_root_object
  price_class                     = var.cloudfront.price_class
  aliases                         = [var.cloudfront.domain]
  web_acl_id                      = aws_wafv2_web_acl.this.arn
  continuous_deployment_policy_id = aws_cloudfront_continuous_deployment_policy.this.id
  wait_for_deployment             = false

  origin {
    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.alb.id
    }

    origin_id   = aws_cloudfront_vpc_origin.alb.id
    domain_name = data.aws_lb.this.dns_name
  }

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

  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront.ordered_cache_behaviors

    content {
      path_pattern             = ordered_cache_behavior.value.path_pattern
      allowed_methods          = ordered_cache_behavior.value.allowed_methods
      cached_methods           = ordered_cache_behavior.value.cached_methods
      target_origin_id         = aws_cloudfront_vpc_origin.alb.id
      cache_policy_id          = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id = ordered_cache_behavior.value.origin_request_policy_id
      viewer_protocol_policy   = ordered_cache_behavior.value.viewer_protocol_policy
    }
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

  depends_on = [
    aws_cloudfront_distribution.staging,
    aws_cloudfront_continuous_deployment_policy.this
  ]
}
