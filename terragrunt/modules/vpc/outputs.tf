output "vpc_id" {
  description = "ID of the application VPC"
  value       = aws_vpc.application.id
}

output "public_subnet_ids_by_az" {
  description = "Public subnet IDs keyed by availability zone"
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "public_subnet_ids" {
  description = "Public subnet IDs for resources such as the ALB"
  value       = [for az in sort(keys(aws_subnet.public)) : aws_subnet.public[az].id]
}
