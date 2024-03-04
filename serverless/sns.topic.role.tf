data "aws_iam_policy_document" "sns_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "sns_topic_role" {
  name               = var.order_confirmed_topic.role_name
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonSNSRole"
  ]
  assume_role_policy = data.aws_iam_policy_document.sns_trust_policy.json
}