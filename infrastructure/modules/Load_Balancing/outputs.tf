output "lb_dns_name" {
  value = aws_lb.ALB.dns_name
}

output "lb_endpoint" {
  value = aws_lb.ALB.dns_name
}

output "webserver_tg" {
  value = aws_lb_target_group.webserver_tg.arn
}