#!/bin/bash

# Fetch your current public IP address
MY_IP=$(curl -s https://api.ipify.org)

# Define your SingleStore IP addresses (replace with actual IPs)
SINGLE_STORE_IPS="<single-store-ip-1>/32,<single-store-ip-2>/32,<single-store-ip-3>/32,<single-store-ip-4>/32"

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

# Run Terraform with the fetched IP, region, and instance type
terraform init -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}"
terraform apply -var "my_ip=${MY_IP}/32" -var "single_store_ips=[${SINGLE_STORE_IPS}]" -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}" -auto-approve

# Fetch the EC2 public IP output from Terraform
EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)

# Run Terraform again to update the EC2 public IP in the Kafka configuration
terraform apply -var "my_ip=${MY_IP}/32" -var "single_store_ips=[${SINGLE_STORE_IPS}]" -var "ec2_public_ip=${EC2_PUBLIC_IP}" -var "region=${AWS_REGION}" -var "instance_type=${INSTANCE_TYPE}" -auto-approve

# Optional: Display the SSH command
echo "SSH into the instance using:"
terraform output ssh_command
