#!/bin/bash

# Ensure the script exits if any command fails
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

# Fetch your current public IP address
MY_IP=$(curl -s https://api.ipify.org)
echo "Current IP Address: $MY_IP"

# Enter IP addresses in a single input
read -p "Enter the SingleStore endpoints (comma-separated): " SINGLE_STORE_IPS_INPUT

# Remove spaces and validate input
SINGLE_STORE_IPS_INPUT=$(echo $SINGLE_STORE_IPS_INPUT | tr -d ' ')

if [[ -z "$SINGLE_STORE_IPS_INPUT" ]]; then
  echo "You must enter at least one IP address."
  exit 1
fi

IFS=',' read -r -a IP_ARRAY <<< "$SINGLE_STORE_IPS_INPUT"

if [[ ${#IP_ARRAY[@]} -ne 4 ]]; then
  echo "Please enter exactly 4 IP addresses."
  exit 1
fi

IP_1=${IP_ARRAY[0]}
IP_2=${IP_ARRAY[1]}
IP_3=${IP_ARRAY[2]}
IP_4=${IP_ARRAY[3]}

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

# Prompt for the key pair name
read -p "Enter the name of your existing EC2 key pair: " KEY_PAIR_NAME

if [[ -z "$KEY_PAIR_NAME" ]]; then
  echo "Key pair name cannot be empty."
  exit 1
fi

# Collect Kafka topics information
TOPICS=()
while true; do
  read -p "Enter a Kafka topic name: " TOPIC_NAME
  read -p "Enter the number of partitions for this topic: " PARTITION_COUNT

  # Add topic information to the list in the correct format
  TOPICS+=("{\"name\": \"${TOPIC_NAME}\", \"partitions\": ${PARTITION_COUNT}}")

  read -p "Do you want to add another topic? (y/n): " ADD_MORE
  if [[ "$ADD_MORE" != "y" ]]; then
    break
  fi
done

# Convert TOPICS array to JSON format (no need to use jq as we are building JSON manually)
TOPICS_JSON=$(printf "[%s]" "$(IFS=,; echo "${TOPICS[*]}")")

# Initialize Terraform with the specified region
terraform init \
  -var "region=${AWS_REGION}" \
  -var "instance_type=${INSTANCE_TYPE}" \
  -var "aws_profile_name=${AWS_PROFILE_NAME}"

# Apply Terraform configuration to create resources
terraform apply \
  -var "my_ip=${MY_IP}/32" \
  -var "single_store_ips=${SINGLE_STORE_IPS_LIST}" \
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

# Wait until the instance is running
echo "Waiting until $INSTANCE_ID is fully running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance $INSTANCE_ID is now running."

echo "EC2 instance name: $EC2_NAME"
echo "EC2 public IP: $EC2_PUBLIC_IP"
echo "You can connect to your instance using:"
echo "ssh -i /path/to/${KEY_PAIR_NAME}.pem ec2-user@${EC2_PUBLIC_IP}"
echo "Kafka topics and partitions: ${TOPICS_JSON}"

# Save all necessary information to a file for teardown
echo "MY_IP=${MY_IP}" > teardown_details.txt
echo "SINGLE_STORE_IPS_LIST='${SINGLE_STORE_IPS_LIST}'" >> teardown_details.txt
echo "AWS_REGION=${AWS_REGION}" >> teardown_details.txt
echo "INSTANCE_TYPE=${INSTANCE_TYPE}" >> teardown_details.txt
echo "AWS_PROFILE_NAME=${AWS_PROFILE_NAME}" >> teardown_details.txt
echo "KEY_PAIR_NAME=${KEY_PAIR_NAME}" >> teardown_details.txt
echo "TOPICS_JSON='${TOPICS_JSON}'" >> teardown_details.txt
