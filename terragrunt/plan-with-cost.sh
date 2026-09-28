#!/usr/bin/env bash
set -Eeuo pipefail

environment="${1:-}"

case "$environment" in
  dev|production|loadtest) ;;
  *)
    echo "Usage: bash terragrunt/plan-with-cost.sh dev|production|loadtest" >&2
    exit 2
    ;;
esac

terragrunt_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
terraform_bin="$(command -v terraform)"
cost_tmp="$(mktemp -d "${TMPDIR:-/tmp}/tg-cost.${environment}.XXXXXX")"

cleanup() {
  rm -f "$cost_tmp"/*.tfplan "$cost_tmp"/*.json
  rmdir "$cost_tmp"
}
trap cleanup EXIT

for unit in \
  vpc \
  app/sg \
  app/alb \
  app/ec2 \
  app/autoscaling \
  app/cloudwatch
do
  module="${unit##*/}"

  echo
  echo "===== $environment / $unit: Terraform plan ====="

  (
    cd "$terragrunt_root/$environment/$unit"

    terragrunt run --tf-path="$terraform_bin" \
      -- plan -out="$cost_tmp/$module.tfplan"
  )

  # terraform show needs the matching provider installed in an initialized
  # Terraform directory. It reads the plan without re-parsing Terragrunt.
  terraform -chdir="$terragrunt_root/modules/$module" \
    init -backend=false -input=false > /dev/null

  terraform -chdir="$terragrunt_root/modules/$module" \
    show -json "$cost_tmp/$module.tfplan" \
    > "$cost_tmp/$module.json"

  python3 -m json.tool "$cost_tmp/$module.json" > /dev/null

  echo
  echo "===== $environment / $unit: Infracost ====="

  infracost scan "$cost_tmp/$module.json"
done
