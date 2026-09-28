locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Name        = "${local.name_prefix}-nodejs-instance"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_autoscaling_group" "nodejs" {
  name = "${local.name_prefix}-nodejs-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period
  default_instance_warmup   = var.default_instance_warmup

  launch_template {
    id      = var.launch_template_id
    version = tostring(var.launch_template_latest_version)
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = var.default_instance_warmup
    }
  }

  dynamic "tag" {
    for_each = local.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]

    precondition {
      condition = (
        var.min_size <= var.desired_capacity &&
        var.desired_capacity <= var.max_size
      )

      error_message = "Expected min_size <= desired_capacity <= max_size."
    }
  }
}

resource "aws_autoscaling_policy" "requests_per_target" {
  name                   = "${local.name_prefix}-requests-per-target"
  autoscaling_group_name = aws_autoscaling_group.nodejs.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = var.default_instance_warmup

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = join("/", [
        var.load_balancer_arn_suffix,
        var.target_group_arn_suffix
      ])
    }

    target_value     = var.requests_per_target_per_minute
    disable_scale_in = false
  }
}
