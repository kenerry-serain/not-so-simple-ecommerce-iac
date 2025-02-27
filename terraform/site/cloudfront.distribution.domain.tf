resource "aws_route53_record" "cloudfront" {
  zone_id         = data.aws_route53_zone.this.zone_id
  name            = var.cloudfront.domain
  type            = "A"
  allow_overwrite = true
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}
