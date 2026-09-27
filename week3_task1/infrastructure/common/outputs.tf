output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  value = aws_vpc.application.id
}

output "public_subnet_ids" {
  value = values(aws_subnet.public)[*].id
}

output "application_url" {
  value = "http://${aws_lb.public_application.dns_name}"
}

output "load_balancer_dns_name" {
  value = aws_lb.public_application.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.nodejs.arn
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.nodejs.name
}

output "application_role_arn" {
  value = aws_iam_role.application.arn
}

output "notification_topic_arn" {
  value = try(aws_sns_topic.scaling_events[0].arn, null)
}
