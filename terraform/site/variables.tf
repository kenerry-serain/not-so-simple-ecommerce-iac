variable "region" {
  default = "us-east-1"
}

variable "tags" {
  type = object({
    Project     = string
    Environment = string
  })

  default = {
    Project     = "nsse",
    Environment = "production"
  }
}

variable "assume_role" {
  type = object({
    role_arn    = string,
    external_id = string
  })

  default = {
    role_arn    = "<YOUR_ROLE>"
    external_id = "<YOUR_EXTERNAL_ID>"
  }
}

variable "cloudfront" {
  type = object({
    s3_site_bucket_name      = string
    s3_site_logs_bucket_name = string
    enabled                  = bool
    default_root_object      = string
    price_class              = string
    domain                   = string
    alb_vpc_origin = object({
      name                   = string
      http_port              = string
      https_port             = string
      origin_protocol_policy = string
      origin_ssl_protocols = object({
        items    = list(string)
        quantity = number
      })
    })
    ordered_cache_behaviors = list(object({
      path_pattern             = string
      allowed_methods          = list(string)
      cached_methods           = list(string)
      cache_policy_id          = string
      origin_request_policy_id = string
      viewer_protocol_policy   = string
    }))
    default_cache_behavior = object({
      allowed_methods        = list(string)
      cached_methods         = list(string)
      cache_policy_id        = string
      viewer_protocol_policy = string
    })
  })

  default = {
    s3_site_bucket_name      = "devopsnanuvem.com"
    s3_site_logs_bucket_name = "devopsnanuvem-com-logs"
    enabled                  = true
    default_root_object      = "index.html"
    price_class              = "PriceClass_All"
    domain                   = "devopsnanuvem.com"
    alb_vpc_origin = {
      name                   = "nsse-internal-alb-vpc-origin"
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = {
        items    = ["TLSv1.2"]
        quantity = 1
      }
    }
    ordered_cache_behaviors = [{
      path_pattern             = "/healthchecks/*"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      viewer_protocol_policy   = "redirect-to-https"
      },
      {
        path_pattern             = "/notificator/*"
        allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods           = ["GET", "HEAD"]
        cache_policy_id          = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
        viewer_protocol_policy   = "redirect-to-https"
      },
      {
        path_pattern             = "/identity/*"
        allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods           = ["GET", "HEAD"]
        cache_policy_id          = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
        viewer_protocol_policy   = "redirect-to-https"
      },
      {
        path_pattern             = "/invoice/*"
        allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods           = ["GET", "HEAD"]
        cache_policy_id          = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
        viewer_protocol_policy   = "redirect-to-https"
      },
      {
        path_pattern             = "/order/*"
        allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods           = ["GET", "HEAD"]
        cache_policy_id          = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
        viewer_protocol_policy   = "redirect-to-https"
      },
      {
        path_pattern             = "/main/*"
        allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods           = ["GET", "HEAD"]
        cache_policy_id          = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
        viewer_protocol_policy   = "redirect-to-https"
    }]
    default_cache_behavior = {
      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]

      # Managed-CachingOptimized
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      viewer_protocol_policy = "redirect-to-https"
    }
  }
}

variable "waf" {
  type = object({
    name  = string
    scope = string
    custom_response_body = object({
      key          = string
      content      = string
      content_type = string
    })
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name                = string
      sampled_requests_enabled   = bool
    })
  })

  default = {
    name  = "waf-devopsnanuvem-com-webacl"
    scope = "CLOUDFRONT"
    custom_response_body = {
      key          = "403-CustomForbiddenResponse"
      content      = "You are not allowed to perform the action you requested."
      content_type = "APPLICATION_JSON"
    }
    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-devopsnanuvem-com-webacl-metrics"
      sampled_requests_enabled   = true
    }
  }
}
