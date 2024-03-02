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
    role_arn    = "arn:aws:iam::<YOUR-ACCOUNT-ID>:role/terraform-role"
    external_id = "<YOUR-EXTERNAL-ID>"
  }
}

variable "public_subnets" {
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))

  default = [
    {
      name                    = "public-subnet-1a"
      availability_zone       = "us-east-1a"
      cidr_block              = "10.0.0.0/27"
      map_public_ip_on_launch = true
    },
    {
      name                    = "public-subnet-1b"
      availability_zone       = "us-east-1b"
      cidr_block              = "10.0.0.64/27"
      map_public_ip_on_launch = true
    }
  ]
}

variable "private_subnets" {
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))

  default = [
    {
      name                    = "private-subnet-1a"
      availability_zone       = "us-east-1a"
      cidr_block              = "10.0.0.32/27"
      map_public_ip_on_launch = false
    },
    {
      name                    = "private-subnet-1b"
      availability_zone       = "us-east-1b"
      cidr_block              = "10.0.0.96/27"
      map_public_ip_on_launch = false
    }
  ]
}

variable "vpc_resources" {
  type = object({
    vpc                       = string,
    vpc_cidr_block            = string,
    elastic_ip_nat_gateway_1a = string,
    elastic_ip_nat_gateway_1b = string,
    internet_gateway          = string,
    nat_gateway_1a            = string,
    nat_gateway_1b            = string,
    private_route_table_1a    = string,
    private_route_table_1b    = string,
    public_route_table        = string,
  })

  default = {
    vpc                       = "nsse-production-vpc",
    vpc_cidr_block            = "10.0.0.0/24",
    elastic_ip_nat_gateway_1a = "eip-nat-gateway-1a",
    elastic_ip_nat_gateway_1b = "eip-nat-gateway-1b",
    internet_gateway          = "internet-gateway",
    nat_gateway_1a            = "nat-gateway-1a",
    nat_gateway_1b            = "nat-gateway-1b",
    private_route_table_1a    = "private-route-table-1a",
    private_route_table_1b    = "private-route-table-1b",
    public_route_table        = "public-route-table",

  }
}
