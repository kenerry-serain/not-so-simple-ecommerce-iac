resource "aws_vpc" "this" {
  cidr_block           = var.vpc_resources.vpc_cidr_block
  enable_dns_hostnames = true

  tags = merge({ Name = var.vpc_resources.vpc }, var.tags)
}
