variable "region" {
  default = "us-east-1"
}

variable "vpc_resources" {
  type = object({
    vpc = string
  })

  default = {
    vpc = "nsse-production-vpc"

  }
}

variable "tags" {
  type = object({
    Project     = string
    Environment = string
  })

  default = {
    Project     = "nsse",
    Environment = "production"
  }
}

variable "assume_role" {
  type = object({
    role_arn    = string,
    external_id = string
  })

  default = {
    role_arn    = "<YOUR_ROLE>"
    external_id = "<YOUR_EXTERNAL_ID>"
  }
}

variable "ec2_resources" {
  type = object({
    key_pair_name                = string,
    instance_profile             = string,
    instance_role                = string,
    control_plane_security_group = string,
    worker_security_group        = string,
  })

  default = {
    key_pair_name                = "nsse-production-key-pair"
    instance_role                = "nsse-production-instance-role"
    instance_profile             = "nsse-production-instance-profile"
    control_plane_security_group = "nsse-production-control-plane-security-group"
    worker_security_group        = "nsse-production-worker-security-group"
  }
}

variable "control_plane_launch_template" {
  type = object({
    name                                 = string
    disable_api_stop                     = bool
    disable_api_termination              = bool
    instance_type                        = string
    instance_initiated_shutdown_behavior = string
    user_data                            = string
    ebs = object({
      size                  = number
      delete_on_termination = bool
    })
  })

  default = {
    name                                 = "nsse-production-debian-control-plane-lt"
    disable_api_stop                     = true
    disable_api_termination              = true
    instance_type                        = "t3.medium"
    instance_initiated_shutdown_behavior = "terminate"
    user_data                            = "./cli/control-plane-user-data.sh"
    ebs = {
      size                  = 20
      delete_on_termination = true
    }
  }
}

variable "worker_launch_template" {
  type = object({
    name                                 = string
    disable_api_stop                     = bool
    disable_api_termination              = bool
    instance_type                        = string
    instance_initiated_shutdown_behavior = string
    user_data                            = string
    ebs = object({
      size                  = number
      delete_on_termination = bool
    })
  })

  default = {
    name                                 = "nsse-production-debian-worker-lt"
    disable_api_stop                     = true
    disable_api_termination              = true
    instance_type                        = "t3.micro"
    instance_initiated_shutdown_behavior = "terminate"
    user_data                            = "./cli/worker-user-data.sh"
    ebs = {
      size                  = 20
      delete_on_termination = true
    }
  }
}

variable "control_plane_auto_scaling_group" {
  type = object({
    name                      = string
    max_size                  = number
    min_size                  = number
    desired_capacity          = number
    health_check_grace_period = number
    health_check_type         = string
    instance_tags = object({
      Name = string
    })
    instance_maintenance_policy = object({
      min_healthy_percentage = number
      max_healthy_percentage = number
    })
  })

  default = {
    name                      = "nsse-production-control-plane-asg"
    max_size                  = 2
    min_size                  = 2
    desired_capacity          = 2
    health_check_grace_period = 180
    health_check_type         = "EC2"
    instance_tags = {
      Name = "nsse-production-control-plane"
    }
    instance_maintenance_policy = {
      min_healthy_percentage = 100
      max_healthy_percentage = 110
    }
  }
}

variable "worker_auto_scaling_group" {
  type = object({
    name                            = string
    max_size                        = number
    min_size                        = number
    desired_capacity                = number
    health_check_grace_period       = number
    health_check_type               = string
    cluster_auto_scaler_policy_name = string
    instance_tags = object({
      Name = string
    })
    instance_maintenance_policy = object({
      min_healthy_percentage = number
      max_healthy_percentage = number
    })
  })

  default = {
    name                            = "nsse-production-worker-asg"
    cluster_auto_scaler_policy_name = "nsse-production-cluster-autoscaler-policy"
    max_size                        = 5
    min_size                        = 2
    desired_capacity                = 2
    health_check_grace_period       = 180
    health_check_type               = "EC2"
    instance_tags = {
      Name = "nsse-production-worker"
    }
    instance_maintenance_policy = {
      min_healthy_percentage = 100
      max_healthy_percentage = 110
    }
  }
}

variable "debian_patch_baseline" {
  type = object({
    name                                 = string
    description                          = string
    approved_patches_enable_non_security = bool
    operating_system                     = string
    approval_rules = list(object({
      approve_after_days = number
      compliance_level   = string
      patch_filter = object({
        product  = list(string)
        section  = list(string)
        priority = list(string)
      })
    }))
  })

  default = {
    name                                 = "DebianProductionPatchBaseline"
    description                          = "Custom Patch Baseline for Debian Production Servers"
    approved_patches_enable_non_security = false
    operating_system                     = "DEBIAN"
    approval_rules = [{
      approve_after_days = 0
      compliance_level   = "CRITICAL"
      patch_filter = {
        product  = ["Debian12"]
        section  = ["*"]
        priority = ["Required", "Important"]
      }
      },
      {
        approve_after_days = 0
        compliance_level   = "INFORMATIONAL"
        patch_filter = {
          product  = ["Debian12"]
          section  = ["*"]
          priority = ["Standard"]
        }
    }]
  }
}

variable "patch_group" {
  type    = string
  default = "Production"
}

variable "debian_production_association" {
  type = object({
    name                = string
    schedule_expression = string
    association_name    = string
    max_concurrency     = number
    max_errors          = number
    output_location = object({
      s3_key_prefix = string
    })
    parameters = object({
      Operation    = string
      RebootOption = string
    })
    targets = object({
      key = string
    })
  })

  default = {
    name                = "AWS-RunPatchBaseline"
    schedule_expression = "cron(*/30 * * * ? *)"
    association_name    = "DebianRunPatchBaselineAssociation"
    max_concurrency     = 1
    max_errors          = 0
    output_location = {
      s3_key_prefix = "patching-logs"
    }
    parameters = {
      Operation    = "Install"
      RebootOption = "RebootIfNeeded"
    }
    targets = {
      key = "tag:PatchGroup"
    }
  }
}

variable "logs_bucket" {
  type = object({
    bucket        = string
    force_destroy = bool
  })

  default = {
    bucket        = "nsse-production-logs"
    force_destroy = true
  }
}

variable "bucket_ssm" {
  type    = string
  default = "not-so-simple-ecommerce-ansible-ssm"
}

variable "network_load_balancer" {
  type = object({
    name               = string
    internal           = bool
    load_balancer_type = string
    default_tg = object({
      name               = string
      target_type        = string
      port               = number
      protocol           = string
      preserve_client_ip = bool
    })
    default_listener = object({
      port     = number
      protocol = string
    })
  })

  default = {
    name               = "nsse-production-cp-nlb"
    internal           = true
    load_balancer_type = "network"
    default_tg = {
      name               = "nsse-production-cp-nlb-tcp-tg"
      target_type        = "instance"
      port               = 6443
      protocol           = "TCP"
      preserve_client_ip = false
    }
    default_listener = {
      port     = 6443
      protocol = "TCP"
    }
  }
}

variable "node_termination" {
  type = object({
    queue_name                = string
    role_name                 = string
    policy_name               = string
    hook_name                 = string
    hook_default_result       = string
    hook_heartbeat_timeout    = number
    hook_lifecycle_transition = string
  })

  default = {
    queue_name                = "NodeTerminationQueue"
    role_name                 = "nsse-production-node-termination-role"
    policy_name               = "nsse-production-node-termination-policy"
    hook_name                 = "NodeTerminationNotification"
    hook_default_result       = "CONTINUE"
    hook_heartbeat_timeout    = 300
    hook_lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
  }
}
