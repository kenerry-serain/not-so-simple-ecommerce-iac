resource "aws_security_group" "postgresql" {
  name        = var.security_groups.rds
  description = "Managing ports for RDS"
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = var.security_groups.rds
  })
}

resource "aws_security_group_rule" "self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.postgresql.id
}

resource "aws_security_group_rule" "control_plane" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.postgresql.id
  source_security_group_id = data.aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "worker" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.postgresql.id
  source_security_group_id = data.aws_security_group.worker.id
}
