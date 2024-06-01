output "key_pair_private_key" {
  sensitive = true
  value     = tls_private_key.this.private_key_pem
}
