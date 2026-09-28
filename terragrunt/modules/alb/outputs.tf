output "load_balancer_dns_name" {
  value = aws_lb.public_application.dns_name
}

output "load_balancer_arn_suffix" {
  value = aws_lb.public_application.arn_suffix
}

output "target_group_arn" {
  value = aws_lb_target_group.nodejs.arn
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.nodejs.arn_suffix
}

output "listener_arn" {
  value = aws_lb_listener.public_http.arn
}

output "application_url" {
  value = "http://${aws_lb.public_application.dns_name}"
}
