output "alb_security_group_id" {
  description = "Security group ID for the public ALB"
  value       = aws_security_group.public_alb.id
}

output "application_security_group_id" {
  description = "Security group ID for the application instances"
  value       = aws_security_group.application.id
}
