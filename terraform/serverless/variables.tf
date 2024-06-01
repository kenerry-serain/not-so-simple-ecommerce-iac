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
    role_arn    = "<YOUR_ROLE>"
    external_id = "7cacab4d-c52c-473c-8db2-883391bc030d"
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
    secret                       = string
    engine                       = string
    engine_mode                  = string
    database_name                = string
    master_username              = string
    final_snapshot_identifier    = string
    preferred_maintenance_window = string
    availability_zones           = list(string)
    deletion_protection          = bool
    storage_encrypted            = bool
    manage_master_user_password  = bool
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
    secret                       = "nsse-aurora-serverless-cluster-secret"
    engine                       = "aurora-postgresql"
    engine_mode                  = "provisioned"
    database_name                = "notSoSimpleEcommerce"
    master_username              = "nsseAdmin"
    final_snapshot_identifier    = "nsse-aurora-serverless-cluster-final-snapshot"
    preferred_maintenance_window = "sun:05:00-sun:06:00"
    availability_zones           = ["us-east-1a", "us-east-1b"]
    deletion_protection          = false
    storage_encrypted            = true
    manage_master_user_password  = true
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

variable "rds_proxy" {
  type = object({
    name                = string
    read_only_endpoint  = string
    debug_logging       = bool
    engine_family       = string
    idle_client_timeout = number
    require_tls         = bool
    role_name           = string
    policy_name         = string
    auth = object({
      auth_scheme = string
      iam_auth    = string
    })
  })

  default = {
    name                = "nsse-aurora-serverless-cluster-proxy"
    read_only_endpoint  = "nsse-aurora-serverless-cluster-proxy-readonly"
    debug_logging       = false
    engine_family       = "POSTGRESQL"
    idle_client_timeout = 300
    require_tls         = true
    role_name           = "nsse-production-rds-proxy-role"
    policy_name         = "nsse-production-rds-proxy-policy"
    auth = {
      auth_scheme = "SECRETS"
      iam_auth    = "DISABLED"
    }
  }
}

variable "lambda_order_confirmed" {
  type = object({
    package_type  = string
    source_dir    = string
    output_path   = string
    filename      = string
    function_name = string
    handler       = string
    runtime       = string
    role_name     = string
    policy_name   = string
  })

  default = {
    package_type  = "zip"
    source_dir    = "lambdas/order-confirmed/build"
    output_path   = "lambdas/order-confirmed/outputs/package.zip"
    filename      = "lambdas/order-confirmed/outputs/package.zip"
    function_name = "orderConfirmedLambdaFunction"
    handler       = "index.handler"
    runtime       = "nodejs18.x"
    role_name     = "nsse-production-order-confirmed-lambda-role"
    policy_name   = "nsse-production-order-confirmed-lambda-policy"
  }
}

variable "lambda_report_job" {
  type = object({
    timeout       = number
    package_type  = string
    source_dir    = string
    output_path   = string
    filename      = string
    function_name = string
    handler       = string
    runtime       = string
    role_name     = string
    policy_name   = string
  })

  default = {
    timeout       = 30
    package_type  = "zip"
    source_dir    = "lambdas/report-job/build"
    output_path   = "lambdas/report-job/outputs/package.zip"
    filename      = "lambdas/report-job/outputs/package.zip"
    function_name = "reportJobLambdaFunction"
    handler       = "index.handler"
    runtime       = "nodejs18.x"
    role_name     = "nsse-production-report-job-lambda-role"
    policy_name   = "nsse-production-report-job-lambda-policy"
  }
}

variable "lambda_layer_node_modules" {
  type = object({
    package_type        = string
    source_dir          = string
    output_path         = string
    filename            = string
    layer_name          = string
    compatible_runtimes = list(string)
  })

  default = {
    package_type        = "zip"
    source_dir          = "lambdas/layers/dependencies"
    output_path         = "lambdas/layers/outputs/node_modules_layer.zip"
    filename            = "lambdas/layers/outputs/node_modules_layer.zip"
    layer_name          = "node_modules"
    compatible_runtimes = ["nodejs18.x"]
  }
}

variable "domain" {
  type    = string
  default = "devopsnanuvem.com"
}

variable "document_db_cluster" {
  type = object({
    cluster_identifier              = string
    database_name                   = string
    s3_certificate_path             = string
    engine                          = string
    master_username                 = string
    backup_retention_period         = number
    preferred_backup_window         = string
    preferred_maintenance_window    = string
    final_snapshot_identifier       = string
    storage_encrypted               = bool
    availability_zones              = list(string)
    enabled_cloudwatch_logs_exports = list(string)
    subnet_group_name               = string
    secret_name                     = string
    instance_class                  = string
    instance_identifier             = string
    security_group_name             = string
    parameter_group = object({
      family     = string
      name       = string
      audit_logs = string
      profiler   = string
    })
  })

  default = {
    cluster_identifier              = "nsse-documentdb-cluster"
    database_name                   = "notSoSimpleEcommerce"
    s3_certificate_path             = "app/documentdb-ca.pem"
    engine                          = "docdb"
    master_username                 = "nsse"
    backup_retention_period         = 7
    preferred_backup_window         = "01:00-02:00"
    preferred_maintenance_window    = "sun:03:00-sun:04:00"
    final_snapshot_identifier       = "nsse-documentdb-cluster-final-snapshot"
    storage_encrypted               = true
    availability_zones              = ["us-east-1a", "us-east-1b"]
    enabled_cloudwatch_logs_exports = ["audit", "profiler"]
    subnet_group_name               = "nsse-documentdb-subnet-group"
    secret_name                     = "nsse-documentdb-secret"
    instance_class                  = "db.t3.medium"
    instance_identifier             = "nsse-document-db-cluster-single-instance"
    security_group_name             = "nsse-documentdb-security-group"
    parameter_group = {
      family     = "docdb5.0"
      name       = "nsse-documentdb-parameter-group"
      audit_logs = "enabled"
      profiler   = "enabled"
    }
  }
}

variable "event_bridge_scheduler_lambda_report_job" {
  type = object({
    schedule_name                 = string
    schedule_group_name           = string
    schedule_flexible_time_window = string
    schedule_expression           = string
    role_name                     = string
    policy_name                   = string
  })

  default = {
    schedule_name                 = "lambda-report-schedule"
    schedule_group_name           = "default"
    schedule_flexible_time_window = "OFF"
    schedule_expression           = "rate(1 minutes)"
    role_name                     = "nsse-production-eb-scheduler-role"
    policy_name                   = "nsse-production-invoke-lambda-policy"
  }
}
