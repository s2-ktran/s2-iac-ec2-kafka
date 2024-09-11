#!/bin/bash

set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION
if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi


read -p "Enter the IP addresses that you would like Kafka to connect with (comma-separated): " IPS_INPUT
IPS_INPUT=$(echo $IPS_INPUT | tr -d ' ') 
if [[ -z "$IPS_INPUT" ]]; then
  echo "You must enter at least one IP address."
  exit 1
fi

IFS=',' read -r -a IP_ARRAY <<< "$IPS_INPUT"
IP_LIST=""
for ip in "${IP_ARRAY[@]}"; do
  if [[ -n "$ip" ]]; then
    IP_LIST+="$ip/32,"
  fi
done
IP_LIST="${IP_LIST%,}" # remove trailing comma

IP_LIST=$(echo "$IP_LIST" | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
echo $IP_LIST

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

# Write the variables to the output script
cat <<EOF > $SCRIPT_DIR/output_vars.sh
#!/bin/bash
export TF_VAR_singlestore_api_key="$TF_VAR_singlestore_api_key"
export AWS_REGION="$AWS_REGION"
export IP_LIST='$IP_LIST'
export MY_IP="$MY_IP"
export AWS_PROFILE_NAME="$AWS_PROFILE_NAME"
export INSTANCE_TYPE="$INSTANCE_TYPE"
export KEY_PAIR_NAME="$KEY_PAIR_NAME"
export TOPICS_JSON='$TOPICS_JSON'
EOF

echo "Variables have been saved to $SCRIPT_DIR/output_vars.sh"
