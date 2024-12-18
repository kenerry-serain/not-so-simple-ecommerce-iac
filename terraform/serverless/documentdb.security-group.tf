resource "aws_security_group" "documentdb" {
  name        = var.document_db_cluster.security_group_name
  description = "Managing ports for DocumentDB"
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = var.document_db_cluster.security_group_name
  })
}

resource "aws_security_group_rule" "documentdb_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.documentdb.id
}

