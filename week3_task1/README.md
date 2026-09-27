# Task 1: Node.js application on AWS with Terraform

This directory contains the Terraform infrastructure for this fork of
[benc-uk/nodejs-demoapp](https://github.com/benc-uk/nodejs-demoapp).

## Architecture

An internet-facing Application Load Balancer forwards requests to a target
group. The target group routes traffic to EC2 instances in an Auto Scaling
group. EC2 user data installs Docker, pulls the application image, and starts
the container. The load balancer checks the application's `/health` endpoint.

## Files

- `user_data/user_data.sh` — commands executed when an EC2 instance starts.
- `infrastructure/common/` — Terraform resource definitions shared by environments.
- `infrastructure/dev/` and `infrastructure/production/` — separate Terraform
  root modules; their `.tf` files link to `common/`.
- `infrastructure/env/` — environment-specific variable values.
- `artillery/load-test.yml` — load test configuration.

## Check the existing dev deployment

Set the AWS CLI profile and region, then run commands from
`infrastructure/dev`:

```bash
export AWS_PROFILE=terraform_lab_user
export AWS_REGION=us-east-1
cd week3_task1/infrastructure/dev

terraform state list
terraform validate
terraform plan -var-file=../env/dev.tfvars
terraform output -raw application_url

The local Terraform state is excluded from Git. A fresh clone does not contain
the state of the existing AWS deployment: do not run apply from that clone
against the same resources without first setting up the correct state.

Notifications
Terraform contains SNS and Auto Scaling notification resources. The email in
the dev variables is a placeholder; receiving email requires a subscription
confirmed by the intended recipient.
