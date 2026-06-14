variable "region" {
  default = "us-east-1"
}

variable "assume_role" {
  type = object({
    role_arn    = string
    external_id = string
  })

  default = {
    role_arn    = "arn:aws:iam::968225077300:role/DevOpsNaNuvemRole-57feb1bd-41ba-47a6-bf6e-babf48ef06ef"
    external_id = "4893a271-b991-45b7-9e3e-67c32873e950"
  }
}

variable "opensearch_master_password" {
  type      = string
  sensitive = true
}

variable "node_instance_role" {
  type    = string
  default = "nsse-production-instance-role"
}

variable "opensearch" {
  type = object({
    domain_name    = string
    engine_version = string
    instance_type  = string
    volume_size    = number
  })

  default = {
    domain_name    = "nsse-logs"
    engine_version = "OpenSearch_2.17"
    instance_type  = "t3.medium.search"
    volume_size    = 20
  }
}
