resource "aws_launch_template" "this" {
  name                                 = var.launch_template.name
  disable_api_stop                     = var.launch_template.disable_api_stop
  disable_api_termination              = var.launch_template.disable_api_termination
  instance_type                        = var.launch_template.instance_type
  key_name                             = var.launch_template.key_name
  image_id                             = var.launch_template.image_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior
  vpc_security_group_ids               = var.launch_template.vpc_security_group_ids
  user_data                            = var.launch_template.user_data

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.launch_template.ebs.size
      delete_on_termination = var.launch_template.ebs.delete_on_termination
    }
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  # hop limit 2 lets pods inside CNI network namespaces reach IMDS at 169.254.169.254.
  # default is 1, which blocks pod-level AWS SDK credential fetch — required for fluent-bit
  # to assume the EC2 instance role and ship logs to OpenSearch via SigV4.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  lifecycle {
    ignore_changes = [ 
      user_data
     ]
  }
}
