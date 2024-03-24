variable "region" {
  default = "us-east-1"
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
    role_arn    = "arn:aws:iam::968225077300:role/terraform-role"
    external_id = "b13a2355-fffa-4c74-a5c1-5869e1e6b2d9"
  }
}

variable "queues" {
  type = list(object({
    name                      = string
    delay_seconds             = number
    max_message_size          = number
    message_retention_seconds = number
    receive_wait_time_seconds = number
    sqs_managed_sse_enabled   = bool
  }))

  default = [{
    name                      = "EmailNotificationQueue"
    delay_seconds             = 0
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
    sqs_managed_sse_enabled   = true
    },
    {
      name                      = "ProductStockQueue"
      delay_seconds             = 0
      max_message_size          = 2048
      message_retention_seconds = 86400
      receive_wait_time_seconds = 10
      sqs_managed_sse_enabled   = true
    },
    {
      name                      = "InvoiceQueue"
      delay_seconds             = 0
      max_message_size          = 2048
      message_retention_seconds = 86400
      receive_wait_time_seconds = 10
      sqs_managed_sse_enabled   = true
  }]
}

variable "dlqueues" {
  type = list(object({
    name                      = string
    delay_seconds             = number
    max_message_size          = number
    message_retention_seconds = number
    receive_wait_time_seconds = number
    sqs_managed_sse_enabled   = bool
  }))

  default = [{
    name                      = "EmailNotificationQueueDlq"
    delay_seconds             = 0
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
    sqs_managed_sse_enabled   = true
    },
    {
      name                      = "ProductStockQueueDlq"
      delay_seconds             = 0
      max_message_size          = 2048
      message_retention_seconds = 86400
      receive_wait_time_seconds = 10
      sqs_managed_sse_enabled   = true
    },
    {
      name                      = "InvoiceQueueDlq"
      delay_seconds             = 0
      max_message_size          = 2048
      message_retention_seconds = 86400
      receive_wait_time_seconds = 10
      sqs_managed_sse_enabled   = true
  }]
}

variable "order_confirmed_topic" {
  type = object({
    name                             = string,
    role_name                        = string,
    sqs_success_feedback_sample_rate = number,
    subscriptions                    = list(string)
  })

  default = {
    role_name                        = "SnsTopicRole"
    name                             = "OrderConfirmedTopic"
    sqs_success_feedback_sample_rate = 100,
    subscriptions                    = ["InvoiceQueue", "ProductStockQueue"]
  }
}

variable "s3_application_bucket_name" {
  type    = string
  default = "nsse-application-bucket"
}

variable "vpc_resources" {
  type = object({
    vpc = string
  })

  default = {
    vpc = "nsse-production-vpc"
  }
}

variable "security_groups" {
  type = object({
    rds           = string,
    control_plane = string,
    worker        = string,
  })

  default = {
    rds           = "nsse-production-rds-security-group"
    control_plane = "nsse-production-control-plane-security-group"
    worker        = "nsse-production-worker-security-group"
  }
}

variable "rds_aurora_cluster" {
  type = object({
    cluster_identifier           = string
    engine                       = string
    engine_mode                  = string
    database_name                = string
    master_username              = string
    final_snapshot_identifier    = string
    preferred_maintenance_window = string
    availability_zones           = list(string)
    deletion_protection          = bool
    manage_master_user_password  = bool
    storage_encrypted            = bool,
    instances = list(object({
      instance_class    = string
      identifier        = string
      availability_zone = string
    }))
    serverless_scaling_configuration = object({
      max_capacity = number
      min_capacity = number
    })
  })

  default = {
    cluster_identifier           = "nsse-aurora-serverless-cluster"
    engine                       = "aurora-postgresql"
    engine_mode                  = "provisioned"
    database_name                = "notSoSimpleEcommerce"
    master_username              = "nsseAdmin"
    final_snapshot_identifier    = "nsse-aurora-serverless-cluster-final-snapshot"
    preferred_maintenance_window = "sun:05:00-sun:06:00"
    availability_zones           = ["us-east-1a", "us-east-1b","us-east-1c"]
    deletion_protection          = true
    manage_master_user_password  = true
    storage_encrypted            = true
    instances = [{
      instance_class    = "db.serverless"
      identifier        = "nsse-instance-us-east-1a"
      availability_zone = "us-east-1a"
      },
      {
        instance_class    = "db.serverless"
        identifier        = "nsse-instance-us-east-1b"
        availability_zone = "us-east-1b"
    }]
    serverless_scaling_configuration = {
      max_capacity = 1.0
      min_capacity = 0.5
    }
  }
}

variable "db_subnet_group" {
  type    = string
  default = "nsse-production-db-subnet-group"
}
