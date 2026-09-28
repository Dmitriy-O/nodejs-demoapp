locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "public_alb" {
  name        = "${local.name_prefix}-public-alb"
  description = "Public HTTP traffic to the application load balancer"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-alb"
  })
}

resource "aws_security_group" "application" {
  name        = "${local.name_prefix}-application"
  description = "Node.js instances behind the load balancer"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-application"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.public_alb.id
  description       = "HTTP from the Internet"

  ip_protocol = "tcp"
  from_port   = var.alb_port
  to_port     = var.alb_port
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
