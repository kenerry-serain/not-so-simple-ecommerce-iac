output "opensearch_endpoint" {
  value       = aws_opensearch_domain.logs.endpoint
  description = "Endpoint do domínio OpenSearch — usar como Host no Fluent Bit (sem https://)"
}

output "opensearch_dashboards_url" {
  value       = "https://${aws_opensearch_domain.logs.endpoint}/_dashboards"
  description = "URL de acesso ao OpenSearch Dashboards"
}
