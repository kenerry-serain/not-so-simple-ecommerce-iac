resource "aws_cloudfront_continuous_deployment_policy" "this" {
  enabled = true

  staging_distribution_dns_names {
    items    = [aws_cloudfront_distribution.staging.domain_name]
    quantity = 1
  }

  traffic_config {
    type = "SingleHeader"
    single_header_config {
      header = "aws-cf-cd-nsse-bg-beta-tester"
      value  = "1"
    }
  }

  depends_on = [aws_cloudfront_distribution.staging]
}
