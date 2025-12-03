resource "aws_lb" "application_load_balancer" {
  name               = "${var.app_name}-${var.app_environment}-lb"
  internal           = false #means internet facing
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name        = "${var.app_name}-lb"
    Environment = var.app_environment
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-${var.app_environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip" #important for fargate
  vpc_id      = aws_vpc.main.id
  tags = {
    Name        = "${var.app_name}-lb-tg"
    Environment = var.app_environment
  }
  health_check {
    path     = "/"
    port     = "8080"
    protocol = "HTTP"
  }
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Add HTTPS listener to ALB
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate_validation.validated.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}


