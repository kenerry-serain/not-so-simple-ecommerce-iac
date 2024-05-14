resource "aws_docdb_subnet_group" "this" {
  name       = var.document_db_cluster.subnet_group_name
  subnet_ids = data.aws_subnets.private_subnets.ids

  tags = merge(var.tags, {
    Name = var.document_db_cluster.subnet_group_name
  })
}
