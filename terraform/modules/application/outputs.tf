output "dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.ecs.dns_name
}
