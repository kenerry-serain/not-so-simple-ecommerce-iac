resource "aws_docdb_cluster" "this" {
  cluster_identifier              = var.document_db_cluster.cluster_identifier
  engine                          = var.document_db_cluster.engine
  master_username                 = var.document_db_cluster.master_username
  master_password                 = jsondecode(aws_secretsmanager_secret_version.first.secret_string)["password"]
  backup_retention_period         = var.document_db_cluster.backup_retention_period
  preferred_backup_window         = var.document_db_cluster.preferred_backup_window
  preferred_maintenance_window    = var.document_db_cluster.preferred_maintenance_window
  final_snapshot_identifier       = var.document_db_cluster.final_snapshot_identifier
  storage_encrypted               = var.document_db_cluster.storage_encrypted
  vpc_security_group_ids          = [aws_security_group.documentdb.id]
  db_subnet_group_name            = aws_docdb_subnet_group.this.name
  availability_zones              = var.document_db_cluster.availability_zones
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name
  enabled_cloudwatch_logs_exports = var.document_db_cluster.enabled_cloudwatch_logs_exports

  lifecycle {
    ignore_changes = [availability_zones]
  }

  tags = var.tags
}
