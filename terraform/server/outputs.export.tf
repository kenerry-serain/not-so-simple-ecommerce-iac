resource "terraform_data" "export_outputs" {
  triggers_replace = timestamp()

  provisioner "local-exec" {
    command = "terraform output -json > outputs.json"
  }

  depends_on = [aws_lb.nlb_control_plane]
}
