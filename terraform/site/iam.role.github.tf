resource "aws_iam_role" "github_frontend" {
  name = "nsse-github-frontend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:kenerry-serain/not-so-simple-ecommerce:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "github_frontend" {
  name = "nsse-github-frontend-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*",
          aws_s3_bucket.staging_site.arn,
          "${aws_s3_bucket.staging_site.arn}/*"
        ]
      },
      {
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution"
        ]
        Effect = "Allow"
        Resource = [
          aws_cloudfront_distribution.this.arn,
          aws_cloudfront_distribution.staging.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_frontend" {
  role       = aws_iam_role.github_frontend.name
  policy_arn = aws_iam_policy.github_frontend.arn
}
