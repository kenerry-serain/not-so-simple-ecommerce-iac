resource "aws_nat_gateway" "us_east_1a" {
  allocation_id = aws_eip.nat_gateway_1a.id
  subnet_id     = local.public_subnet_1a_id

  tags          = merge({ Name = "${var.vpc_resources.vpc}-${var.vpc_resources.nat_gateway_1a}" }, var.tags)
  depends_on    = [aws_eip.nat_gateway_1a]
}

resource "aws_nat_gateway" "us_east_1b" {
  allocation_id = aws_eip.nat_gateway_1b.id
  subnet_id     = local.public_subnet_1b_id
  
  tags          = merge({ Name = "${var.vpc_resources.vpc}-${var.vpc_resources.nat_gateway_1b}" }, var.tags)
  depends_on    = [aws_eip.nat_gateway_1b]
}
