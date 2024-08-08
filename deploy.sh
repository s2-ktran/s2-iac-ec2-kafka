#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Fetch your current public IP address
MY_IP=$(curl -s https://api.ipify.org)

# Define your SingleStore IP addresses
SINGLE_STORE_IPS="52.39.174.38/32,44.230.94.214/32,35.81.56.251/32,52.35.160.52/32"

# Convert the comma-separated IP addresses to a format acceptable by Terraform
SINGLE_STORE_IPS_LIST=$(echo $SINGLE_STORE_IPS | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
  
# Prompt for the AWS region
read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION

# Validate the region
if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi

# Prompt for the EC2 instance type
read -p "Enter the EC2 instance type (default is t2.large): " INSTANCE_TYPE

# Set default instance type if none is provided
INSTANCE_TYPE=${INSTANCE_TYPE:-t2.large}

# Initialize Terraform with the specified region
terraform init -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}"

# Apply Terraform configuration to create resources
terraform apply -var "my_ip=${MY_IP}/32" -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}" -auto-approve

# Fetch the EC2 public IP output from Terraform
EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)

# Apply Terraform configuration again to update the EC2 public IP in Kafka configuration
terraform apply -var "my_ip=${MY_IP}/32" -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" -var "ec2_public_ip=${EC2_PUBLIC_IP}" -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}" -auto-approve

# Optional: Display the SSH command
echo "SSH into the instance using:"
terraform output ssh_command

