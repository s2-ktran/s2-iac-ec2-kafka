#!/bin/bash

# Ensure the script exits if any command fails
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/



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

# Prompt for the AWS region
read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION

if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi

export AWS_PROFILE_NAME=$(aws sts get-caller-identity --query UserId --output text | awk -F':' '{print $2}' | awk -F'@' '{print $1}')

# Initialize Terraform with the specified region
terraform init \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32"

# Apply Terraform configuration to create resources
terraform destroy \
  -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32" \
  -auto-approve

echo "Infrastructure destroyed successfully."
