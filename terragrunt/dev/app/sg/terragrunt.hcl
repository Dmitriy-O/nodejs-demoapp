include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules/sg"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }
}

inputs = {
  project_name = local.env.project_name
  environment  = local.env.environment
  vpc_id       = dependency.vpc.outputs.vpc_id
  alb_port     = local.env.alb_port
  app_port     = local.env.app_port
}
