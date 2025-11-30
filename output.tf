output "aws_loadbalancer_dns_name" {
  value       = aws_lb.application_load_balancer.dns_name
  description = "The DNS name of the application load balancer"
  depends_on  = [aws_lb.application_load_balancer]
}

output "ecr_repository_url" {
  value = aws_ecr_repository.aws_ecr.repository_url
}
