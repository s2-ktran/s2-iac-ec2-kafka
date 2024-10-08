#!/bin/bash

# Script presetup
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

. $SCRIPT_DIR/output_vars.sh
. $SCRIPT_DIR/../terraform/teardown_details.txt

# Removing PEM file
echo "Removing PEM file"
rm -f $SCRIPT_DIR/../ec2_key.pem
echo "Successfully removed PEM file."

# Terraform
terraform init \
  -var "region=${AWS_REGION}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32" \
  -var "kafka_topics=${TOPICS_JSON}" \
  -var "key_name=${KEY_PAIR_NAME}"

echo "Destroying remaining AWS infrastructure..."
terraform destroy \
  -var "ip_list=${IP_LIST}" \
  -var "region=${AWS_REGION}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}" \
  -var "my_ip=${MY_IP}/32" \
  -var "key_name=${KEY_PAIR_NAME}" \
  -var "kafka_topics=${TOPICS_JSON}" \
  -auto-approve

echo "All infrastructure destroyed successfully."