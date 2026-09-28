locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic" "scaling_events" {
  count = var.enable_notifications ? 1 : 0

  name = "${local.name_prefix}-scaling-events"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-scaling-events"
  })
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_notifications && var.enable_email_subscription ? 1 : 0

  topic_arn = aws_sns_topic.scaling_events[0].arn
  protocol  = "email"
  endpoint  = var.notification_email

  lifecycle {
    precondition {
      condition     = trimspace(var.notification_email) != ""
      error_message = "Set notification_email when enabling the email subscription."
    }
  }
}

resource "aws_autoscaling_notification" "application" {
  count = var.enable_notifications ? 1 : 0

  group_names = [var.autoscaling_group_name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.scaling_events[0].arn
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  count = var.enable_notifications ? 1 : 0

  alarm_name        = "${local.name_prefix}-unhealthy-targets"
  alarm_description = "ALB has one or more unhealthy targets"

  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [aws_sns_topic.scaling_events[0].arn]
  ok_actions    = [aws_sns_topic.scaling_events[0].arn]
}
