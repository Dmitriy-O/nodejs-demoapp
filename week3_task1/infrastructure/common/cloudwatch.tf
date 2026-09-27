resource "aws_autoscaling_policy" "requests_per_target" {
  name                   = "${local.name_prefix}-requests-per-target"
  autoscaling_group_name = aws_autoscaling_group.nodejs.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = var.default_instance_warmup

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = join(
        "/",
        [
          aws_lb.public_application.arn_suffix,
          aws_lb_target_group.nodejs.arn_suffix
        ]
      )
    }

    target_value     = var.requests_per_target_per_minute
    disable_scale_in = false
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  count = local.notifications_enabled ? 1 : 0

  alarm_name        = "${local.name_prefix}-unhealthy-targets"
  alarm_description = "ALB has one or more unhealthy targets"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.public_application.arn_suffix
    TargetGroup  = aws_lb_target_group.nodejs.arn_suffix
  }

  alarm_actions = [aws_sns_topic.scaling_events[0].arn]
  ok_actions    = [aws_sns_topic.scaling_events[0].arn]
}
