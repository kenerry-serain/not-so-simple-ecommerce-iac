resource "aws_s3_bucket_policy" "staging_cloudfront" {
  bucket = aws_s3_bucket.staging_site.id
  policy = data.aws_iam_policy_document.allow_oac_access_staging.json
}

data "aws_iam_policy_document" "allow_oac_access_staging" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.staging_site.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.this.arn,
        aws_cloudfront_distribution.staging.arn,
      ]
    }
  }
}
