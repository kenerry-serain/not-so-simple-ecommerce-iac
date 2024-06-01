resource "aws_secretsmanager_secret" "documentdb" {
  name = var.document_db_cluster.secret_name

  tags = var.tags
}

data "aws_secretsmanager_random_password" "documentdb" {
  password_length     = 30
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret_version" "first" {
  secret_id = aws_secretsmanager_secret.documentdb.id
  secret_string = jsonencode({
    username = var.document_db_cluster.master_username,
    password = data.aws_secretsmanager_random_password.documentdb.random_password
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
