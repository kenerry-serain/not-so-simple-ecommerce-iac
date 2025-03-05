resource "aws_security_group" "alb" {
  name        = var.ec2_resources.alb_security_group
  description = "Managing ports for ALB"
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = var.ec2_resources.alb_security_group })
}

resource "aws_security_group_rule" "alb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  security_group_id = aws_security_group.alb.id
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
}
