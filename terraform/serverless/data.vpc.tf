data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_resources.vpc]
  }
}