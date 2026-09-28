output "launch_template_id" {
  value = aws_launch_template.nodejs.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.nodejs.latest_version
}

output "application_role_arn" {
  value = aws_iam_role.application.arn
}
