# ---------- Application Load Balancer and Target Group ----------
# Application Load Balancer
resource "aws_lb" "ALB" {
  name               = "InternalHTTPS"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.private_subnets
  security_groups    = [var.security_groups]

  tags = {
    Name = "Internal_HTTPS"
  }
}

# Application Load Balancer Listener Rule
resource "aws_lb_listener" "ALB_Listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver_tg.arn
  }
}

# Application Load Balancer Target Group
resource "aws_lb_target_group" "webserver_tg" {
  name     = "aws-lb-target"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
    protocol            = "HTTPS"
    port                = 443
  }
}