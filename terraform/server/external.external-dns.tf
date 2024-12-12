data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:route53:::hostedzone/*"]
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]
  }
}

resource "aws_iam_policy" "external_dns_policy" {
  name   = "nsse-production-external-dns-policy"
  policy = data.aws_iam_policy_document.external_dns_policy.json
}

resource "aws_iam_role_policy_attachment" "external_dns_policy" {
  policy_arn = aws_iam_policy.external_dns_policy.arn
  role       = aws_iam_role.instance_role.name
}
