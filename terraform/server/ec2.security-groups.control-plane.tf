resource "aws_security_group" "control_plane" {
  name        = var.ec2_resources.control_plane_security_group
  description = "Managing ports for control plane nodes"
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = var.ec2_resources.control_plane_security_group })
}

resource "aws_security_group_rule" "self_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.control_plane.id
  self              = true
}

resource "aws_security_group_rule" "allow_workers_traffic" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.worker.id
}
