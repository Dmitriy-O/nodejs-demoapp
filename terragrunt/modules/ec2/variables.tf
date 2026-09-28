variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "application_security_group_id" {
  description = "Security group assigned to application EC2 instances"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
}

variable "docker_image" {
  description = "Pinned GHCR image for the Node.js application"
  type        = string
}

variable "app_port" {
  type = number
}

variable "health_check_path" {
  type = string
}
