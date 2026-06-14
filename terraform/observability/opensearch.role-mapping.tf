resource "opensearch_roles_mapping" "all_access" {
  role_name     = "all_access"
  backend_roles = [data.aws_iam_role.node.arn]
  users         = ["admin"]

  depends_on = [aws_opensearch_domain.logs]
}
