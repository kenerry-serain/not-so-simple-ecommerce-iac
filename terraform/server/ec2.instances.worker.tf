module "ec2_workers_instances" {
  source                = "./modules/ec2"
  instance_profile_name = aws_iam_instance_profile.instance_profile.name
  launch_template = {
    name                                 = var.worker_launch_template.name
    disable_api_stop                     = var.worker_launch_template.disable_api_stop
    disable_api_termination              = var.worker_launch_template.disable_api_termination
    instance_type                        = var.worker_launch_template.instance_type
    instance_initiated_shutdown_behavior = var.worker_launch_template.instance_initiated_shutdown_behavior
    key_name                             = aws_key_pair.this.key_name
    image_id                             = data.aws_ami.this.image_id
    vpc_security_group_ids               = [aws_security_group.worker.id]
    user_data                            = filebase64(var.worker_launch_template.user_data)
    ebs = {
      size                  = var.worker_launch_template.ebs.size
      delete_on_termination = var.worker_launch_template.ebs.delete_on_termination
    }
  }
  auto_scaling_group = {
    name                      = var.worker_auto_scaling_group.name
    max_size                  = var.worker_auto_scaling_group.max_size
    min_size                  = var.worker_auto_scaling_group.min_size
    desired_capacity          = var.worker_auto_scaling_group.desired_capacity
    health_check_grace_period = var.worker_auto_scaling_group.health_check_grace_period
    health_check_type         = var.worker_auto_scaling_group.health_check_type
    vpc_zone_identifier       = data.aws_subnets.private_subnets.ids
    target_group_arns         = []
    instance_tags = merge(
      { PatchGroup = var.patch_group },
      {
        "k8s.io/cluster-autoscaler/enabled" = true,
        "k8s.io/cluster-autoscaler/devops-na-nuvem-cluster" = "owned",
        "aws-node-termination-handler/managed" = true,
        "kubernetes.io/cluster/devops-na-nuvem-cluster" = "owned"
      },
      var.tags,
      var.worker_auto_scaling_group.instance_tags
    )
    instance_maintenance_policy = {
      min_healthy_percentage = var.worker_auto_scaling_group.instance_maintenance_policy.min_healthy_percentage
      max_healthy_percentage = var.worker_auto_scaling_group.instance_maintenance_policy.max_healthy_percentage
    }
  }
  tags = var.tags
}
