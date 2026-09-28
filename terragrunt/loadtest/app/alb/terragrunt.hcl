include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules/alb"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"

    public_subnet_ids = [
      "subnet-00000000000000000",
      "subnet-11111111111111111"
    ]
  }
}

dependency "sg" {
  config_path = "../sg"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    alb_security_group_id = "sg-00000000000000000"
  }
}

inputs = {
  project_name               = local.env.project_name
  environment                = local.env.environment
  vpc_id                     = dependency.vpc.outputs.vpc_id
  public_subnet_ids          = dependency.vpc.outputs.public_subnet_ids
  alb_security_group_id      = dependency.sg.outputs.alb_security_group_id
  alb_port                   = local.env.alb_port
  app_port                   = local.env.app_port
  health_check_path          = local.env.health_check_path
  enable_deletion_protection = local.env.enable_deletion_protection
}
