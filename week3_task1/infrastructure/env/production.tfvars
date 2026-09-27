aws_region   = "us-east-1"
project_name = "nodejs-demo"
environment  = "production"

vpc_cidr = "10.30.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.30.1.0/24",
  "10.30.2.0/24"
]

instance_type    = "t3.small"
root_volume_size = 20

min_size         = 2
desired_capacity = 2
max_size         = 6

app_port          = 3000
health_check_path = "/health"

docker_image = "ghcr.io/dmitriy-o/nodejs-demoapp:sha-754337480dbb6cfa916f062f04adac1b73297534"

health_check_grace_period      = 300
default_instance_warmup        = 300
requests_per_target_per_minute = 1000

enable_deletion_protection = false
enable_notifications       = false
notification_email         = ""
