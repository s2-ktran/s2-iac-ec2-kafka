#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Determine the base directory of the project (iac-ec2-kafka)
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "Base directory: $BASE_DIR"

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

# Initialize Terraform with the specified region
terraform init \
  -var "region=${AWS_REGION}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32" \
  -var "kafka_topics=${TOPICS_JSON}" \
  -var "key_name=${KEY_PAIR_NAME}"

# Destroy Terraform-managed infrastructure
terraform destroy \
  -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" \
  -var "region=${AWS_REGION}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32" \
  -var "kafka_topics=${TOPICS_JSON}" \
  -var "key_name=${KEY_PAIR_NAME}" \
  -auto-approve

echo "Infrastructure destroyed successfully."
