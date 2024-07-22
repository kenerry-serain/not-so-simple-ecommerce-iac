output "launch_template_name" {
  value = aws_launch_template.this.name
}

output "auto_scaling_group_name" {
  value = aws_autoscaling_group.this.name
}

output "auto_scaling_group_arn" {
  value = aws_autoscaling_group.this.arn
}