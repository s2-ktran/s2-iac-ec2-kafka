#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Prompt for the AWS region
read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION

# Validate the region
if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi

# Initialize Terraform with the specified region
terraform init -var "region=${AWS_REGION}"

# Destroy the Terraform-managed infrastructure
terraform destroy -var "region=${AWS_REGION}" -auto-approve

echo "Terraform infrastructure has been destroyed."
