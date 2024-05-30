variable "region" {
  default = "us-east-1"
}

variable "assume_role" {
  type = object({
    role_arn    = string,
    external_id = string
  })

  default = {
    role_arn    = "arn:aws:iam::654654554686:role/terraform-role"
    external_id = "7cacab4d-c52c-473c-8db2-883391bc030d"
  }
}

variable "s3_bucket" {
  type = string
  default = "nsse-terraform-state-bucket-654654554686"
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

