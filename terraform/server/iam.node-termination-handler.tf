data "aws_iam_policy_document" "ecr_public_login" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
  }
}

resource "aws_iam_policy" "ecr_public_login" {
  name   = "node-termination-handler-policy"
  policy = data.aws_iam_policy_document.ecr_public_login.json
}

resource "aws_iam_role_policy_attachment" "ecr_public_login" {
  policy_arn = aws_iam_policy.ecr_public_login.arn
  role       = aws_iam_role.instance_role.name
}
