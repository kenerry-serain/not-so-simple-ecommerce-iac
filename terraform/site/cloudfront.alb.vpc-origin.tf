resource "aws_cloudfront_vpc_origin" "alb" {
  vpc_origin_endpoint_config {
    name                   = var.cloudfront.alb_vpc_origin.name
    arn                    = data.aws_lb.this.arn
    http_port              = var.cloudfront.alb_vpc_origin.http_port
    https_port             = var.cloudfront.alb_vpc_origin.https_port
    origin_protocol_policy = var.cloudfront.alb_vpc_origin.origin_protocol_policy

    origin_ssl_protocols {
      items    = var.cloudfront.alb_vpc_origin.origin_ssl_protocols.items
      quantity = var.cloudfront.alb_vpc_origin.origin_ssl_protocols.quantity
    }
  }
}
