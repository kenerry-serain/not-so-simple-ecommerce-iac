data "archive_file" "node_modules_layer" {
  type        = var.lambda_layer_node_modules.package_type
  source_dir  = "${path.module}/${var.lambda_layer_node_modules.source_dir}"
  output_path = "${path.module}/${var.lambda_layer_node_modules.output_path}"
}

resource "aws_lambda_layer_version" "node_modules" {
  filename            = "${path.module}/${var.lambda_layer_node_modules.filename}"
  layer_name          = var.lambda_layer_node_modules.layer_name
  compatible_runtimes = var.lambda_layer_node_modules.compatible_runtimes
}
