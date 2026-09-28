variable "project_name" {
  description = "Project name used in AWS resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, production, or loadtest"
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Availability zone to public subnet CIDR mapping"
  type        = map(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "Provide public subnets in at least two availability zones."
  }
}

variable "tags" {
  description = "Additional tags applied to the network resources"
  type        = map(string)
  default     = {}
}
