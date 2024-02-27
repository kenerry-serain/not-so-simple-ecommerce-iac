variable "tags" {
  type = object({
    Project     = string
    Environment = string
  })
}

variable "instance_profile_name" {
  type = string
}

variable "launch_template" {
  type = object({
    name                                 = string
    disable_api_stop                     = bool
    disable_api_termination              = bool
    instance_type                        = string
    instance_initiated_shutdown_behavior = string
    user_data                            = string
    key_name                             = string
    image_id                             = string
    vpc_security_group_ids               = list(string)
    ebs = object({
      size                  = number
      delete_on_termination = bool
    })
  })
}

variable "auto_scaling_group" {
  type = object({
    name                      = string
    max_size                  = number
    min_size                  = number
    desired_capacity          = number
    health_check_grace_period = number
    health_check_type         = string
    vpc_zone_identifier       = list(string)
    instance_tags = object({
      Project     = string
      Environment = string
      PatchGroup  = string
      Name        = string
    })
    instance_maintenance_policy = object({
      min_healthy_percentage = number
      max_healthy_percentage = number
    })
  })
}
