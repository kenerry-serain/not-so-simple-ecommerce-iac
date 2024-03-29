resource "aws_security_group" "postgresql" {
  name        = var.security_groups.rds
  description = "Managing ports for RDS"
  vpc_id      = data.aws_vpc.this.id


 ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      data.aws_security_group.worker.id,
    ]
  }

    ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      data.aws_security_group.control_plane.id,
    ]
  }
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
