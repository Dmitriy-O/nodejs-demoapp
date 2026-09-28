include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules/ec2"
}

dependency "sg" {
  config_path = "../sg"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    application_security_group_id = "sg-00000000000000000"
  }
}

inputs = {
  project_name                  = local.env.project_name
  environment                   = local.env.environment
  application_security_group_id = dependency.sg.outputs.application_security_group_id

  instance_type     = local.env.instance_type
  root_volume_size  = local.env.root_volume_size
  docker_image      = local.env.docker_image
  app_port          = local.env.app_port
  health_check_path = local.env.health_check_path
}
