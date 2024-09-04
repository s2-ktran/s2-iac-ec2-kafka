#!/bin/bash

# Script presetup
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

# Variables
# read -p "Enter your SingleStore API Key: " TF_VAR_singlestore_api_key
# if [ -z "$TF_VAR_singlestore_api_key" ]; then
#     echo "Please set the TF_VAR_singlestore_api_key environment variable"
#     exit 1
# fi

read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION
if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi

read -p "Enter the first SingleStore endpoint: " IP_1
read -p "Enter the second SingleStore endpoint: " IP_2
read -p "Enter the third SingleStore endpoint: " IP_3
read -p "Enter the fourth SingleStore endpoint: " IP_4
echo "These 4 IP addresses you entered are: $IP_1, $IP_2, $IP_3, $IP_4"
SINGLE_STORE_IPS="$IP_1/32,$IP_2/32,$IP_3/32,$IP_4/32"
SINGLE_STORE_IPS_LIST=$(echo $SINGLE_STORE_IPS | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
echo $SINGLE_STORE_IPS_LIST

MY_IP=$(curl -s https://api.ipify.org)
echo "Current IP Address: $MY_IP"

export AWS_PROFILE_NAME=$(aws sts get-caller-identity --query UserId --output text | awk -F':' '{print $2}' | awk -F'@' '{print $1}')

read -p "Enter the EC2 instance type (default is t2.large): " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-t2.large}

read -p "Enter the name of the key pair you want to provision: " KEY_PAIR_NAME
if [[ -z "$KEY_PAIR_NAME" ]]; then
  echo "Key pair name cannot be empty."
  exit 1
fi

# Terraform deployment
terraform init \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE}"

terraform apply \
  -var "my_ip=${MY_IP}/32" \
  -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE}" \
  -var "key_name=${KEY_PAIR_NAME}" \
  -auto-approve
  # -var "singlestore_api_key=${TF_VAR_singlestore_api_key}" \

# Capture the Terraform outputs
EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)
INSTANCE_ID=$(terraform output -raw ec2_instance_id)
EC2_NAME=$(terraform output -raw ec2_name)

terraform output -json > outputs.json

# Wait until the instance is running
echo "Waiting until $INSTANCE_ID is fully running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance $INSTANCE_ID is now running."

# Outputting variables
echo "EC2 instance name: $EC2_NAME"
echo "EC2 public IP: $EC2_PUBLIC_IP"
echo "You can connect to your instance using:"
echo "SSH command: ssh -i \"ec2_key.pem\" ec2-user@ec2-$(echo $EC2_PUBLIC_IP | tr '.' '-').$AWS_REGION.compute.amazonaws.com"


