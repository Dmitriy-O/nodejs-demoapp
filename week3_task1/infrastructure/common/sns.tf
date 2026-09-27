resource "aws_sns_topic" "scaling_events" {
  count = var.enable_notifications ? 1 : 0

  name = "${var.project_name}-${var.environment}-scaling-events"

  tags = {
    Name        = "${var.project_name}-${var.environment}-scaling-events"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_notifications && var.enable_email_subscription && trimspace(var.notification_email) != "" ? 1 : 0

  topic_arn = aws_sns_topic.scaling_events[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_autoscaling_notification" "application" {
  count = var.enable_notifications ? 1 : 0

  group_names = [
    aws_autoscaling_group.nodejs.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.scaling_events[0].arn
}
