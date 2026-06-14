data "aws_iam_role" "node" {
  name = var.node_instance_role
}

resource "aws_iam_role_policy" "fluentbit_opensearch" {
  name = "nsse-fluentbit-opensearch-write"
  role = data.aws_iam_role.node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["es:ESHttp*"]
      Resource = "${aws_opensearch_domain.logs.arn}/*"
    }]
  })
}
