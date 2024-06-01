resource "aws_security_group" "worker" {
  name        = var.ec2_resources.worker_security_group
  description = "Managing ports for worker nodes"
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = var.ec2_resources.worker_security_group })
}
