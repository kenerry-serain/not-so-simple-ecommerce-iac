variable "region" {
  default = "us-east-1"
}

variable "assume_role" {
  type = object({
    role_arn    = string,
    external_id = string
  })

  default = {
    role_arn    = "arn:aws:iam::968225077300:role/terraform-role"
    external_id = "183f7a68-72a9-11ee-b962-0242ac120002"
  }
}

variable "s3_bucket" {
  type = string
  default = "nsse-terraform-state-bucket"
}

variable "dynamo_table" {
  type = object({
    name = string
    billing_mode = string,
    hash_key = string,
  })

  default = {
    name = "nsse-terraform-state-lock-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
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

