data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "node_termination_queue_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "sqs.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.node_termination.queue_name}"]
  }
}


data "aws_iam_policy_document" "node_termination_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_sqs_queue" "node_termination" {
  name                      = var.node_termination.queue_name
  message_retention_seconds = 300
  policy                    = data.aws_iam_policy_document.node_termination_queue_policy.json
  tags                      = var.tags
}

resource "aws_iam_role" "node_termination" {
  name               = var.node_termination.role_name
  assume_role_policy = data.aws_iam_policy_document.node_termination_trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
  ]
}

data "aws_iam_policy_document" "node_termination" {
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

resource "aws_iam_policy" "node_termination" {
  name   = var.node_termination.policy_name
  policy = data.aws_iam_policy_document.node_termination.json
}

resource "aws_iam_role_policy_attachment" "node_termination" {
  policy_arn = aws_iam_policy.node_termination.arn
  role       = aws_iam_role.instance_role.name
}

resource "aws_autoscaling_lifecycle_hook" "node_termination" {
  name                    = var.node_termination.hook_name
  autoscaling_group_name  = module.ec2_workers_instances.auto_scaling_group_name
  default_result          = var.node_termination.hook_default_result
  heartbeat_timeout       = var.node_termination.hook_heartbeat_timeout
  lifecycle_transition    = var.node_termination.hook_lifecycle_transition
  notification_target_arn = aws_sqs_queue.node_termination.arn
  role_arn                = aws_iam_role.node_termination.arn
}
