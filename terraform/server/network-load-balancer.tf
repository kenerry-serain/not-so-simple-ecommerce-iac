resource "aws_lb" "nlb_control_plane" {
  name               = var.network_load_balancer.name
  internal           = var.network_load_balancer.internal
  load_balancer_type = var.network_load_balancer.load_balancer_type
  subnets            = data.aws_subnets.private_subnets.ids
  security_groups    = [aws_security_group.control_plane.id]
  tags               = var.tags
}
