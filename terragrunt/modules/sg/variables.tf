variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC containing the load balancer and application"
  type        = string
}

variable "alb_port" {
  description = "Public HTTP port on the ALB"
  type        = number
}

variable "app_port" {
  description = "Port exposed by the application instances"
  type        = number
}
