variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_subnet_ids" {
  description = "Subnets where Auto Scaling launches application instances"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Provide at least two subnet IDs."
  }
}

variable "target_group_arn" {
  description = "ALB target group receiving application instances"
  type        = string
}

variable "load_balancer_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "launch_template_id" {
  type = string
}

variable "launch_template_latest_version" {
  type = number
}

variable "min_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "health_check_grace_period" {
  type = number
}

variable "default_instance_warmup" {
  type = number
}

variable "requests_per_target_per_minute" {
  type = number
}
