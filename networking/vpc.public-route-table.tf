resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags       = merge({ Name = "${var.vpc_resources.vpc}-${var.vpc_resources.public_route_table}" }, var.tags)
  depends_on = [aws_vpc.this]
}

resource "aws_route_table_association" "public_associations" {
  count = length(aws_subnet.publics)

  subnet_id      = aws_subnet.publics[count.index].id
  route_table_id = aws_route_table.public.id
  depends_on     = [aws_route_table.public]
}
