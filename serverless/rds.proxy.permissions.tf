
resource "aws_iam_role" "rds_proxy_role" {
  name = var.rds_proxy.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "rds.amazonaws.com",
      }
    }]
  })
}

resource "aws_iam_policy" "rds_proxy_policy" {
  name        = var.rds_proxy.policy_name
  description = "Policy for RDS Proxy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
      ],
      Resource = aws_rds_cluster.this.master_user_secret[0].secret_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_proxy_policy_attachment" {
  policy_arn = aws_iam_policy.rds_proxy_policy.arn
  role       = aws_iam_role.rds_proxy_role.name
}
