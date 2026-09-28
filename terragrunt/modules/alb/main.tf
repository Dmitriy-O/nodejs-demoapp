locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb" "public_application" {
  name = substr(
    "${local.name_prefix}-public-alb",
    0,
    32
  )

  load_balancer_type = "application"
  internal           = false

  security_groups = [var.alb_security_group_id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-alb"
  })
}

resource "aws_lb_target_group" "nodejs" {
  name = substr(
    "${local.name_prefix}-nodejs-tg",
    0,
    32
  )

  port        = var.app_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  slow_start = 30

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nodejs-target-group"
  })
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public_application.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodejs.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-http"
  })
}
