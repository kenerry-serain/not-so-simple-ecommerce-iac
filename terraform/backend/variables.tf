variable "region" {
  default = "us-east-1"
}

variable "assume_role" {
  type = object({
    role_arn    = string,
    external_id = string
  })

  default = {
    role_arn    = "arn:aws:iam::968225077300:role/DevOpsNaNuvemRole-57feb1bd-41ba-47a6-bf6e-babf48ef06ef"
    external_id = "4893a271-b991-45b7-9e3e-67c32873e950"
  }
}

variable "remote_backend" {
  type = object({
    bucket = string,
    state_locking = object({
      dynamodb_table_name = string
      dynamodb_table_billing_mode = string
      dynamodb_table_hash_key = string
      dynamodb_table_hash_key_type = string
    })
  })

  default = {
    bucket = "nsse-terraform-state-files"
    state_locking = {
      dynamodb_table_name = "nsse-terraform-state-locking"
      dynamodb_table_billing_mode = "PAY_PER_REQUEST"
      dynamodb_table_hash_key = "LockID"
      dynamodb_table_hash_key_type = "S"
    }
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

