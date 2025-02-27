data "aws_route53_zone" "this" {
  name     = var.cloudfront.domain
}
