output "key_pair_private_key" {
  sensitive = true
  value     = tls_private_key.this.private_key_pem
}

output "nlb_dns_name" {
  value = aws_lb.nlb_control_plane.dns_name
}