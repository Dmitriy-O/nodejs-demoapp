variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC for the application target group"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets in at least two Availability Zones"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The public ALB requires at least two public subnets."
  }
}

variable "alb_security_group_id" {
  description = "Security group assigned to the ALB"
  type        = string
}

variable "alb_port" {
  description = "Port receiving public HTTP requests"
  type        = number
}

variable "app_port" {
  description = "Port used by the EC2 application targets"
  type        = number
}

variable "health_check_path" {
  description = "Application health endpoint"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Prevent accidental ALB deletion"
  type        = bool
}
