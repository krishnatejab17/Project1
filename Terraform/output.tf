output "aws_loadbalancer_dns_name" {
  value       = aws_alb.application_load_balancer.dns_name
  description = "The DNS name of the application load balancer"
  depends_on  = [aws_alb.application_load_balancer]
}
