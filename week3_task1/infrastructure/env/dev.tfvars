aws_region   = "us-east-1"
project_name = "nodejs-demo"
environment  = "dev"

vpc_cidr = "10.20.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

instance_type    = "t3.micro"
root_volume_size = 12

min_size         = 1
desired_capacity = 1
max_size         = 3

app_port          = 3000
health_check_path = "/health"

docker_image = "ghcr.io/dmitriy-o/nodejs-demoapp:sha-754337480dbb6cfa916f062f04adac1b73297534"

health_check_grace_period      = 300
default_instance_warmup        = 300
requests_per_target_per_minute = 100

enable_deletion_protection = false
enable_notifications       = true
notification_email         = "dummy@mail.com"

enable_documentdb  = false
connect_documentdb = false

documentdb_subnet_cidrs = {
  "us-east-1a" = "10.20.101.0/24"
  "us-east-1b" = "10.20.102.0/24"
}

documentdb_instance_class = "db.t3.medium"
