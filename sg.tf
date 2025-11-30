#security group for LB
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "${var.app_name}-lb-sg"
    Environment = var.app_environment
  }
}

#security group for ECS service tasks

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8080      
    to_port         = 8080       
    protocol        = "tcp"     
    security_groups = [aws_security_group.load_balancer_security_group.id]  # Only ALB SG can access
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"] 
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.app_environment
  }
}

