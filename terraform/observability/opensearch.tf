resource "aws_opensearch_domain" "logs" {
  domain_name    = var.opensearch.domain_name
  engine_version = var.opensearch.engine_version

  cluster_config {
    instance_type  = var.opensearch.instance_type
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.opensearch.volume_size
    volume_type = "gp3"
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = var.opensearch_master_password
    }
  }

  # Principal: * é necessário quando se usa internal user database com FGAC.
  # O FGAC é a camada real de autenticação — sem ele esta policy daria acesso livre.
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "*" }
      Action    = "es:ESHttp*"
      Resource  = "arn:aws:es:us-east-1:968225077300:domain/${var.opensearch.domain_name}/*"
    }]
  })

  tags = {
    Project     = "nsse"
    Environment = "production"
  }
}
