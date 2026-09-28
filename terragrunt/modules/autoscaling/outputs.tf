output "autoscaling_group_name" {
  value = aws_autoscaling_group.nodejs.name
}

output "scaling_policy_arn" {
  value = aws_autoscaling_policy.requests_per_target.arn
}
