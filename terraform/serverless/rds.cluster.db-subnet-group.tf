resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group
  subnet_ids = data.aws_subnets.private_subnets.ids
  tags       = var.tags
}
