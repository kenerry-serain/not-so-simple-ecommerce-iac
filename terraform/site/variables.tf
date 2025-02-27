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
    default_cache_behavior = {
      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]

      # Managed-CachingOptimized
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      viewer_protocol_policy = "redirect-to-https"
    }
  }
}

