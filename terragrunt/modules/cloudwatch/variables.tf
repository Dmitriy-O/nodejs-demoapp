variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_notifications" {
  type = bool
}

variable "enable_email_subscription" {
  type = bool
}

variable "notification_email" {
  description = "Optional SNS email recipient; supply outside Git"
  type        = string
  default     = ""
  sensitive   = true
}

variable "autoscaling_group_name" {
  type = string
}

variable "load_balancer_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}
