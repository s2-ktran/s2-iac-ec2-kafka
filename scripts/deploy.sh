#!/bin/bash

# Script presetup
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

. $SCRIPT_DIR/output_vars.sh

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


