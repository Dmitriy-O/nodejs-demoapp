locals {
  project_name = "nodejs-demo"
  environment  = "production"
  vpc_cidr     = "10.30.0.0/16"

  alb_port = 80
  app_port = 3000

  public_subnet_cidrs = {
    "us-east-1a" = "10.30.1.0/24"
    "us-east-1b" = "10.30.2.0/24"
  }
}
