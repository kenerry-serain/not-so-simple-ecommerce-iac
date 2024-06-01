resource "aws_docdb_cluster_parameter_group" "this" {
  family = var.document_db_cluster.parameter_group.family
  name   = var.document_db_cluster.parameter_group.name

  parameter {
    name  = "audit_logs"
    value = var.document_db_cluster.parameter_group.audit_logs
  }

  parameter {
    name  = "profiler"
    value = var.document_db_cluster.parameter_group.profiler
  }
}
