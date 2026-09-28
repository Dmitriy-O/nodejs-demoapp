include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules/vpc"
}

inputs = {
  project_name        = local.env.project_name
  environment         = local.env.environment
  vpc_cidr            = local.env.vpc_cidr
  public_subnet_cidrs = local.env.public_subnet_cidrs
}
