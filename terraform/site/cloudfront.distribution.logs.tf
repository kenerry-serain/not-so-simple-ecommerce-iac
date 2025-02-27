resource "aws_cloudwatch_log_delivery_source" "cloudfront_distribution" {
  name         = "${aws_cloudfront_distribution.this.id}-logs"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.this.arn
}

resource "aws_cloudwatch_log_delivery_destination" "s3_bucket" {
  name = "${aws_s3_bucket.site_logs.bucket}"

  delivery_destination_configuration {
    destination_resource_arn = aws_s3_bucket.site_logs.arn
  }
}

resource "aws_cloudwatch_log_delivery" "cloudfront_s3" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.cloudfront_distribution.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3_bucket.arn
}