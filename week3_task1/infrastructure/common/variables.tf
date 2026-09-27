variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment such as dev or production"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) ==
      length(var.availability_zones)
    )

    error_message = "Each Availability Zone must have one public subnet."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 12
}

variable "min_size" {
  description = "Minimum ASG size"
  type        = number
}

variable "desired_capacity" {
  description = "Initial ASG capacity"
  type        = number
}

variable "max_size" {
  description = "Maximum ASG size"
  type        = number
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "ALB health endpoint"
  type        = string
  default     = "/health"
}

variable "docker_image" {
  description = "Immutable public GHCR image"
  type        = string

  validation {
    condition = (
      startswith(var.docker_image, "ghcr.io/") &&
      !endswith(var.docker_image, ":latest")
    )

    error_message = "Use a versioned or SHA-tagged GHCR image."
  }
}

variable "health_check_grace_period" {
  description = "Startup grace period in seconds"
  type        = number
  default     = 300
}

variable "default_instance_warmup" {
  description = "Scaling warmup in seconds"
  type        = number
  default     = 300
}

variable "requests_per_target_per_minute" {
  description = "Target ALB requests per instance per minute"
  type        = number
  default     = 100
}

variable "enable_deletion_protection" {
  description = "Protect ALB from deletion"
  type        = bool
  default     = false
}

variable "enable_notifications" {
  description = "Create SNS and CloudWatch notifications"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Notification email"
  type        = string
  default     = ""
}
