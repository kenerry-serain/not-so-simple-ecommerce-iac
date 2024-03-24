resource "aws_rds_cluster_instance" "this" {
  count              = length(var.rds_aurora_cluster.instances)
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.rds_aurora_cluster.instances[count.index].instance_class
  availability_zone  = var.rds_aurora_cluster.instances[count.index].availability_zone
  identifier         = var.rds_aurora_cluster.instances[count.index].identifier
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
}
