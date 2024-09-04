#!/bin/bash

# Script presetup
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

# Set the script directory to where the script is located
SCRIPT_DIR="$BASE_DIR/scripts"
echo "Script directory: $SCRIPT_DIR"

# Set the terraform directory path
TERRAFORM_DIR="$BASE_DIR/terraform"
echo "Terraform directory: $TERRAFORM_DIR"

cd "$TERRAFORM_DIR"

# Fetch necessary details from the teardown_details.txt file
source "$TERRAFORM_DIR/teardown_details.txt"

echo "Using saved configuration from teardown_details.txt"
echo "Current IP Address: $MY_IP"
echo "SingleStore IPs: $SINGLE_STORE_IPS_LIST"
echo "AWS Region: $AWS_REGION"
echo "Instance Type: $INSTANCE_TYPE"
echo "AWS Profile Name: $AWS_PROFILE_NAME"
echo "Key Pair Name: $KEY_PAIR_NAME"
echo "Kafka Topics and Partitions: $TOPICS_JSON"
# Fetch your current public IP address
MY_IP=$(curl -s https://api.ipify.org)

# Enter SingleStore API key
# read -sp "Enter your SingleStore API key: " SINGLESTORE_API_KEY
# export TF_VAR_singlestore_api_key="$SINGLESTORE_API_KEY"
read -p "Enter the first SingleStore endpoint: " IP_1
read -p "Enter the second SingleStore endpoint: " IP_2
read -p "Enter the third SingleStore endpoint: " IP_3
read -p "Enter the fourth SingleStore endpoint: " IP_4

# Removing PEM file
echo "Removing PEM file"
rm $SCRIPT_DIR/../ec2_key.pem
echo "Successfully removed PEM file."

# Terraform
terraform init \
  -var "region=${AWS_REGION}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32" \
  -var "kafka_topics=${TOPICS_JSON}" \
  -var "key_name=${KEY_PAIR_NAME}"

# Destroy SingleStore resources first
# echo "Destroying SingleStore resources..."
# terraform destroy \
#   -target=singlestoredb_workspace.example \
#   -target=singlestoredb_workspace_group.example \
#   -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" \
#   -var "region=${AWS_REGION}" \
#   -var "aws_profile_name=${AWS_PROFILE_NAME}" \
#   -var "my_ip=${MY_IP}/32" \
#   -auto-approve

echo "Destroying remaining AWS infrastructure..."
terraform destroy \
  -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" \
  -var "region=${AWS_REGION}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32" \
  -var "key_name=${KEY_PAIR_NAME}" \
  -auto-approve

echo "All infrastructure, including SingleStore resources, destroyed successfully."