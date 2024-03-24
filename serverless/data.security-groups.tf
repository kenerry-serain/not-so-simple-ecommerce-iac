data "aws_security_group" "worker" {
  filter {
    name   = "tag:Name"
    values = [var.security_groups.worker]
  }
}

data "aws_security_group" "control_plane" {
  filter {
    name   = "tag:Name"
    values = [var.security_groups.control_plane]
  }
}
