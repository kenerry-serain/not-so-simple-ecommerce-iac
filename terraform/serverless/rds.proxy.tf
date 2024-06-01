resource "aws_db_proxy" "this" {
  name                = var.rds_proxy.name
  debug_logging       = var.rds_proxy.debug_logging
  engine_family       = var.rds_proxy.engine_family
  idle_client_timeout = var.rds_proxy.idle_client_timeout
  require_tls         = var.rds_proxy.require_tls

  role_arn = aws_iam_role.rds_proxy_role.arn

  vpc_security_group_ids = [aws_security_group.postgresql.id]
  vpc_subnet_ids         = data.aws_subnets.private_subnets.ids

  auth {
    auth_scheme = var.rds_proxy.auth.auth_scheme
    iam_auth    = var.rds_proxy.auth.iam_auth
    secret_arn  = aws_rds_cluster.this.master_user_secret[0].secret_arn
  }

  tags = var.tags
}
