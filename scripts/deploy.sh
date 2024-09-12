#!/bin/bash

# Script presetup
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

. $SCRIPT_DIR/output_vars.sh

# Initialize Terraform with the specified region
terraform init \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}"

terraform apply \
  -var "my_ip=${MY_IP}/32" \
  -var "ip_list=${IP_LIST}" \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "key_name=${KEY_PAIR_NAME}" \
  -var "kafka_topics=${TOPICS_JSON}" \
  -auto-approve

# Capture the Terraform outputs
EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)
INSTANCE_ID=$(terraform output -raw ec2_instance_id)
EC2_NAME=$(terraform output -raw ec2_name)

terraform output -json > outputs.json

# Wait until the instance is running
echo "Waiting until $INSTANCE_ID is fully running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance $INSTANCE_ID is now running."

# Save all necessary information to a file for teardown
echo "MY_IP=${MY_IP}" > teardown_details.txt
echo "IPS_LIST='${IP_LIST}'" >> teardown_details.txt
echo "AWS_REGION=${AWS_REGION}" >> teardown_details.txt
echo "INSTANCE_TYPE=${INSTANCE_TYPE}" >> teardown_details.txt
echo "AWS_PROFILE_NAME=${AWS_PROFILE_NAME}" >> teardown_details.txt
echo "KEY_PAIR_NAME=${KEY_PAIR_NAME}" >> teardown_details.txt
echo "TOPICS_JSON='${TOPICS_JSON}'" >> teardown_details.txt

# Wait for instance to be running
echo "Waiting for the instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is running."

# Wait for the system status to be OK
echo "Waiting for the system status to be OK..."
aws ec2 wait system-status-ok --instance-ids $INSTANCE_ID
echo "System status is OK."

# Outputting variables
echo "EC2 instance name: $EC2_NAME"
echo "EC2 public IP: $EC2_PUBLIC_IP"
echo "Kafka topics and partitions: ${TOPICS_JSON}"
echo "You can connect to your instance using:"
echo "SSH command: ssh -i \"ec2_key.pem\" ec2-user@ec2-$(echo $EC2_PUBLIC_IP | tr '.' '-').$AWS_REGION.compute.amazonaws.com"