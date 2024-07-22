data "aws_iam_policy_document" "cluster_autoscaler" {
    statement {
        effect = "Allow"
        resources = ["*"]
        actions = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:GetInstanceTypesFromInstanceRequirements"
        ]
    }

    statement {
        effect = "Allow"
        resources = [module.ec2_workers_instances.auto_scaling_group_arn]
        actions = [
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = var.worker_auto_scaling_group.cluster_auto_scaler_policy_name
  policy        = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.instance_role.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.instance_role.name
}