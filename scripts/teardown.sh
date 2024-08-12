#!/bin/bash

# Ensure the script exits if any command fails
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

# Prompt for the AWS region
read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION

# Fetch your current public IP address
MY_IP=$(curl -s https://api.ipify.org)

# TODO: Pull in SingleStore IP addresses using bash
# Define your SingleStore IP addresses
SINGLE_STORE_IPS="52.39.174.38/32,44.230.94.214/32,35.81.56.251/32,52.35.160.52/32"

# Convert the comma-separated IP addresses to a format acceptable by Terraform
SINGLE_STORE_IPS_LIST=$(echo $SINGLE_STORE_IPS | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')

# Validate the region
if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi

# Initialize Terraform with the specified region
terraform init -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}"

# Apply Terraform configuration to create resources
terraform destroy -var "my_ip=${MY_IP}/32" -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}" -auto-approve

echo "Infrastructure destroyed successfully."
