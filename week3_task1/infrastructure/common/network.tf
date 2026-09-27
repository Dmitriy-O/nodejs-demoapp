resource "aws_vpc" "application" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.application.id

  tags = {
    Name = "${local.name_prefix}-internet-gateway"
  }
}

resource "aws_subnet" "public" {
  for_each = zipmap(
    var.availability_zones,
    var.public_subnet_cidrs
  )

  vpc_id                  = aws_vpc.application.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.application.id

  tags = {
    Name = "${local.name_prefix}-public-routes"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public_alb" {
  name        = "${local.name_prefix}-public-alb"
  description = "Public HTTP traffic to the application load balancer"
  vpc_id      = aws_vpc.application.id

  tags = {
    Name = "${local.name_prefix}-public-alb"
  }
}

resource "aws_security_group" "application" {
  name        = "${local.name_prefix}-application"
  description = "Node.js instances behind the load balancer"
  vpc_id      = aws_vpc.application.id

  tags = {
    Name = "${local.name_prefix}-application"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.public_alb.id
  description       = "HTTP from the Internet"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id = aws_security_group.public_alb.id
  description       = "ALB traffic to Node.js instances"

  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.application.id
}

resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id = aws_security_group.application.id
  description       = "Node.js traffic only from the ALB"

  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.public_alb.id
}

resource "aws_vpc_security_group_egress_rule" "application_outbound" {
  security_group_id = aws_security_group.application.id
  description       = "Packages, GHCR and AWS APIs"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_lb" "public_application" {
  name = substr(
    "${local.name_prefix}-public-alb",
    0,
    32
  )

  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.public_alb.id]
  subnets         = values(aws_subnet.public)[*].id

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${local.name_prefix}-public-alb"
  }
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
  vpc_id      = aws_vpc.application.id

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

  tags = {
    Name = "${local.name_prefix}-nodejs-target-group"
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public_application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodejs.arn
  }

  tags = {
    Name = "${local.name_prefix}-public-http"
  }
}
