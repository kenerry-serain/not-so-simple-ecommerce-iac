resource "aws_rds_cluster" "this" {
  cluster_identifier           = var.rds_aurora_cluster.cluster_identifier
  engine                       = var.rds_aurora_cluster.engine
  engine_mode                  = var.rds_aurora_cluster.engine_mode
  database_name                = var.rds_aurora_cluster.database_name
  master_username              = var.rds_aurora_cluster.master_username
  availability_zones           = var.rds_aurora_cluster.availability_zones
  final_snapshot_identifier    = var.rds_aurora_cluster.final_snapshot_identifier
  preferred_maintenance_window = var.rds_aurora_cluster.preferred_maintenance_window
  deletion_protection          = var.rds_aurora_cluster.deletion_protection
  manage_master_user_password  = var.rds_aurora_cluster.manage_master_user_password
  storage_encrypted            = var.rds_aurora_cluster.storage_encrypted
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.postgresql.id]

  serverlessv2_scaling_configuration {
    max_capacity = var.rds_aurora_cluster.serverless_scaling_configuration.max_capacity
    min_capacity = var.rds_aurora_cluster.serverless_scaling_configuration.min_capacity
  }

  lifecycle {
    ignore_changes = [availability_zones]
  }

  tags = var.tags
}
