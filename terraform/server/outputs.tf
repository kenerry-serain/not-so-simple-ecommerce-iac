output "key_pair_private_key" {
  sensitive = true
  value     = tls_private_key.this.private_key_pem
}

output "nlb_dns_name" {
  value = aws_lb.nlb_control_plane.dns_name
}

output "worker_launch_template_id" {
  value = module.ec2_workers_instances.launch_template_id
}

output "worker_auto_scaling_group_name" {
  value = module.ec2_workers_instances.auto_scaling_group_name
}

output "node_termination_queue_url"{
  value = aws_sqs_queue.termination.id
}