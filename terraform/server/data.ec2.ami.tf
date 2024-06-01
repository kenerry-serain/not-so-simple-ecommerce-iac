data "aws_ami" "this" {
  most_recent  = true
  owners       = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-12*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
