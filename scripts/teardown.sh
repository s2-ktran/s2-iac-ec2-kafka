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

# Enter in dbEndpoint, username, and password
read -p "Enter the first SingleStore endpoint: " IP_1
read -p "Enter the second SingleStore endpoint: " IP_2
read -p "Enter the third SingleStore endpoint: " IP_3
read -p "Enter the fourth SingleStore endpoint: " IP_4

# Export the variables
echo "These 4 IP addresses you entered are: $IP_1, $IP_2, $IP_3, $IP_4"
SINGLE_STORE_IPS="$IP_1/32,$IP_2/32,$IP_3/32,$IP_4/32"
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
