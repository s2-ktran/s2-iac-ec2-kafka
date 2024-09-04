#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Check if the API key is provided
if [ -z "$TF_VAR_singlestore_api_key" ]; then
    echo "Please set the TF_VAR_singlestore_api_key environment variable"
    exit 1
fi

# Set default region if not provided
TF_VAR_region=${TF_VAR_region:-"us-east-1"}

# Change to the terraform directory
cd "$(dirname "$0")/../terraform" || exit

# Initialize Terraform
terraform init

# Plan and apply Terraform changes
terraform plan -var "region=$TF_VAR_region"
terraform apply -var "region=$TF_VAR_region" -auto-approve

# Extract SingleStore endpoints
endpoints=$(terraform output -json workspace_endpoints | jq -r '.[]')

echo "SingleStore Workspace Endpoints:"
echo "$endpoints"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

# Fetch your current public IP address
MY_IP=$(curl -s https://api.ipify.org)
echo "Current IP Address: $MY_IP"

# Enter in dbEndpoint, username, and password
read -p "Enter the first SingleStore endpoint: " IP_1
read -p "Enter the second SingleStore endpoint: " IP_2
read -p "Enter the third SingleStore endpoint: " IP_3
read -p "Enter the fourth SingleStore endpoint: " IP_4

# Export the variables
echo "These 4 IP addresses you entered are: $IP_1, $IP_2, $IP_3, $IP_4"
SINGLE_STORE_IPS="$IP_1/32,$IP_2/32,$IP_3/32,$IP_4/32"

# Convert the comma-separated IP addresses to a format acceptable by Terraform
SINGLE_STORE_IPS_LIST=$(echo $SINGLE_STORE_IPS | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
echo $SINGLE_STORE_IPS_LIST
  
# Prompt for the AWS region
read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION

if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi

# Pull AWS profile_name
export AWS_PROFILE_NAME=$(aws sts get-caller-identity --query UserId --output text | awk -F':' '{print $2}' | awk -F'@' '{print $1}')

# Prompt for the EC2 instance type
read -p "Enter the EC2 instance type (default is t2.large): " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-t2.large}

# Initialize Terraform with the specified region
terraform init \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE}"

# Apply Terraform configuration to create resources
terraform apply \
  -var "my_ip=${MY_IP}/32" \
  -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -auto-approve

# Capture the Terraform outputs
EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)
INSTANCE_ID=$(terraform output -raw ec2_instance_id)

# Wait until the instance is running
echo "Waiting until $INSTANCE_ID is fully running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance $INSTANCE_ID is now running."


