include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules/cloudwatch"
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    load_balancer_arn_suffix = "app/mock/0123456789abcdef"
    target_group_arn_suffix  = "targetgroup/mock/0123456789abcdef"
  }
}

dependency "autoscaling" {
  config_path = "../autoscaling"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    autoscaling_group_name = "${local.env.project_name}-${local.env.environment}-nodejs-asg"
  }
}

inputs = {
  project_name              = local.env.project_name
  environment               = local.env.environment
  enable_notifications      = local.env.enable_notifications
  enable_email_subscription = local.env.enable_email_subscription

  autoscaling_group_name = dependency.autoscaling.outputs.autoscaling_group_name

  load_balancer_arn_suffix = dependency.alb.outputs.load_balancer_arn_suffix
  target_group_arn_suffix  = dependency.alb.outputs.target_group_arn_suffix
}
