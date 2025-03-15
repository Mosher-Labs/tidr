output "public_ip" {
  description = "IP addresses of ECS service"
  value       = data.aws_network_interface.this.association[0].public_ip
}
