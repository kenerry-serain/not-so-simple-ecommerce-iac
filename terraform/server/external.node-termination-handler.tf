# Fetch the current region
data "aws_region" "current" {}

# Fetch the current account ID
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "termination_sqs_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "sqs.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:NodeTerminationQueue"]
  }
}

data "aws_iam_policy_document" "termination_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "termination" {
  name = "nsse-production-termination-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
  ]
  assume_role_policy = data.aws_iam_policy_document.termination_trust_policy.json
}

resource "aws_sqs_queue" "termination" {
  name                      = "NodeTerminationQueue"
  message_retention_seconds = "300"
  sqs_managed_sse_enabled   = true
  policy = data.aws_iam_policy_document.termination_sqs_policy.json
  tags = var.tags
}

resource "aws_autoscaling_lifecycle_hook" "termination" {
  name                   = "TerminationNotification"
  autoscaling_group_name = module.ec2_workers_instances.auto_scaling_group_name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sqs_queue.termination.arn
  role_arn                = aws_iam_role.termination.arn
}