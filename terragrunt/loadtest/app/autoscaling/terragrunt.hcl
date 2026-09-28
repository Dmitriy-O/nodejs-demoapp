include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules/autoscaling"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    public_subnet_ids = [
      "subnet-00000000000000000",
      "subnet-11111111111111111"
    ]
  }
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:047472448571:targetgroup/mock/0123456789abcdef"

    load_balancer_arn_suffix = "app/mock/0123456789abcdef"
    target_group_arn_suffix  = "targetgroup/mock/0123456789abcdef"
  }
}

dependency "ec2" {
  config_path = "../ec2"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    launch_template_id             = "lt-00000000000000000"
    launch_template_latest_version = 1
  }
}

inputs = {
  project_name = local.env.project_name
  environment  = local.env.environment

  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids

  target_group_arn         = dependency.alb.outputs.target_group_arn
  load_balancer_arn_suffix = dependency.alb.outputs.load_balancer_arn_suffix
  target_group_arn_suffix  = dependency.alb.outputs.target_group_arn_suffix

  launch_template_id             = dependency.ec2.outputs.launch_template_id
  launch_template_latest_version = dependency.ec2.outputs.launch_template_latest_version

  min_size                       = local.env.min_size
  desired_capacity               = local.env.desired_capacity
  max_size                       = local.env.max_size
  health_check_grace_period      = local.env.health_check_grace_period
  default_instance_warmup        = local.env.default_instance_warmup
  requests_per_target_per_minute = local.env.requests_per_target_per_minute
}
