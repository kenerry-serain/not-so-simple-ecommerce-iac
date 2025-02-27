data "aws_acm_certificate" "this" {
  domain   = var.cloudfront.domain
  statuses = ["ISSUED"]
}
