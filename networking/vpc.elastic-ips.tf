resource "aws_eip" "nat_gateway_1a" {
  domain = "vpc"
  tags   = merge({ Name = "${var.vpc_resources.vpc}-${var.vpc_resources.elastic_ip_nat_gateway_1a}" }, var.tags)
}

resource "aws_eip" "nat_gateway_1b" {
  domain = "vpc"
  tags   = merge({ Name = "${var.vpc_resources.vpc}-${var.vpc_resources.elastic_ip_nat_gateway_1b}" }, var.tags)
}
