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
